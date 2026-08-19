require "rails_helper"

describe Users::RegistrationsController do
  before { request.env["devise.mapping"] = Devise.mappings[:user] }

  let(:captcha_id) { "TEST-CAPTCHA-ID-001" }
  let(:valid_params) do
    { user: { username: "newuser", email: "newuser@consul.org",
              password: "12345678", password_confirmation: "12345678",
              terms_of_service: "1", address: "" }}
  end

  before do
    allow(PttCaptcha.configuration).to receive(:app_id).and_return("TEST-APP")
  end

  describe "GET #new" do
    context "when PttCaptcha app_id is configured" do
      it "generates a captcha and stores it in session" do
        allow(PttCaptchaApi).to receive(:create_captcha).and_return(captcha_id)
        get :new
        expect(session[:ptt_captcha_id]).to eq(captcha_id)
      end
    end

    context "when PttCaptcha app_id is blank" do
      before { allow(PttCaptcha.configuration).to receive(:app_id).and_return("") }

      it "does not call PttCaptchaApi" do
        expect(PttCaptchaApi).not_to receive(:create_captcha)
        get :new
      end

      it "does not set captcha id in session" do
        get :new
        expect(session[:ptt_captcha_id]).to be_nil
      end
    end
  end

  describe "POST #create" do
    before do
      InvisibleCaptcha.timestamp_enabled = false
      allow(PttCaptchaApi).to receive(:create_captcha).and_return(captcha_id)
      session[:ptt_captcha_id] = captcha_id
    end

    after { InvisibleCaptcha.timestamp_enabled = true }

    context "when captcha is valid" do
      before { allow(PttCaptchaApi).to receive(:validate_captcha).with(captcha_id, "1234").and_return(true) }

      it "creates the user" do
        expect do
          post :create, params: valid_params.merge(ptt_valor_captcha: "1234")
        end.to change(User, :count).by(1)
      end
    end

    context "when captcha is invalid" do
      before { allow(PttCaptchaApi).to receive(:validate_captcha).and_return(false) }

      it "does not create the user" do
        expect do
          post :create, params: valid_params.merge(ptt_valor_captcha: "wrong")
        end.not_to change(User, :count)
      end

      it "shows alert flash" do
        post :create, params: valid_params.merge(ptt_valor_captcha: "wrong")
        expect(flash[:alert]).to be_present
      end

      it "deletes old captcha and generates a new one" do
        new_captcha_id = "NEW-CAPTCHA-ID-002"
        allow(PttCaptchaApi).to receive(:create_captcha).and_return(new_captcha_id)
        post :create, params: valid_params.merge(ptt_valor_captcha: "wrong")
        expect(session[:ptt_captcha_id]).to eq(new_captcha_id)
      end
    end

    context "security: captcha id comes from session, not params" do
      it "validates against session id, ignoring any forged param" do
        allow(PttCaptchaApi).to receive(:validate_captcha).and_return(true)
        post :create, params: valid_params.merge(ptt_valor_captcha: "1234",
                                                 ptt_captcha_id: "FORGED-ID")
        expect(PttCaptchaApi).to have_received(:validate_captcha).with(captcha_id, anything)
      end
    end
  end

  describe "Google reCAPTCHA fallback" do
    before do
      allow(PttCaptcha.configuration).to receive(:app_id).and_return("")
      InvisibleCaptcha.timestamp_enabled = false
    end

    after { InvisibleCaptcha.timestamp_enabled = true }

    context "when site_key and secret_key are configured" do
      before do
        allow(Rails.application.secrets).to receive(:site_key).and_return("SITE-KEY")
        allow(Rails.application.secrets).to receive(:secret_key).and_return("SECRET-KEY")
      end

      it "does not request a PTT captcha on #new" do
        expect(PttCaptchaApi).not_to receive(:create_captcha)
        get :new
      end

      it "creates the user when the recaptcha verification succeeds" do
        allow(controller).to receive(:verify_recaptcha).and_return(true)
        expect { post :create, params: valid_params }.to change(User, :count).by(1)
      end

      it "does not create the user when the recaptcha verification fails" do
        allow(controller).to receive(:verify_recaptcha).and_return(false)
        expect { post :create, params: valid_params }.not_to change(User, :count)
        expect(flash[:alert]).to be_present
      end
    end

    context "when neither PTT nor Google secrets are configured" do
      before do
        allow(Rails.application.secrets).to receive(:site_key).and_return("")
        allow(Rails.application.secrets).to receive(:secret_key).and_return("")
      end

      it "does not request a PTT captcha on #new" do
        expect(PttCaptchaApi).not_to receive(:create_captcha)
        get :new
      end

      it "creates the user without any captcha check" do
        expect { post :create, params: valid_params }.to change(User, :count).by(1)
      end

      it "does not render any captcha widget", render_views: true do
        get :new
        expect(response.body).not_to include("data-captcha-id")
        expect(response.body).not_to include("g-recaptcha")
      end
    end
  end
end
