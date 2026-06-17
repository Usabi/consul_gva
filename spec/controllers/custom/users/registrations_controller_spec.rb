require "rails_helper"

describe Users::RegistrationsController do
  before { request.env["devise.mapping"] = Devise.mappings[:user] }

  let(:captcha_id) { "TEST-CAPTCHA-ID-001" }
  let(:valid_params) do
    { user: { username: "newuser", email: "newuser@consul.org",
              password: "12345678", password_confirmation: "12345678",
              terms_of_service: "1", address: "" } }
  end

  before do
    allow(Rails.application.secrets).to receive(:ptt_app_id).and_return("TEST-APP")
  end

  describe "GET #new" do
    context "when ptt_app_id is configured" do
      it "generates a captcha and stores it in session" do
        allow(PttCaptchaApi).to receive(:crear).and_return(captcha_id)
        get :new
        expect(session[:ptt_captcha_id]).to eq(captcha_id)
      end
    end

    context "when ptt_app_id is blank" do
      before { allow(Rails.application.secrets).to receive(:ptt_app_id).and_return("") }

      it "does not call PttCaptchaApi" do
        expect(PttCaptchaApi).not_to receive(:crear)
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
      allow(PttCaptchaApi).to receive(:crear).and_return(captcha_id)
      session[:ptt_captcha_id] = captcha_id
    end

    after { InvisibleCaptcha.timestamp_enabled = true }

    context "when captcha is valid" do
      before { allow(PttCaptchaApi).to receive(:validar).with(captcha_id, "1234").and_return(true) }

      it "creates the user" do
        expect do
          post :create, params: valid_params.merge(ptt_valor_captcha: "1234")
        end.to change(User, :count).by(1)
      end
    end

    context "when captcha is invalid" do
      before { allow(PttCaptchaApi).to receive(:validar).and_return(false) }

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
        allow(PttCaptchaApi).to receive(:crear).and_return(new_captcha_id)
        post :create, params: valid_params.merge(ptt_valor_captcha: "wrong")
        expect(session[:ptt_captcha_id]).to eq(new_captcha_id)
      end
    end

    context "security: captcha id comes from session, not params" do
      it "validates against session id, ignoring any forged param" do
        allow(PttCaptchaApi).to receive(:validar).and_return(true)
        post :create, params: valid_params.merge(ptt_valor_captcha: "1234",
                                                 ptt_captcha_id: "FORGED-ID")
        expect(PttCaptchaApi).to have_received(:validar).with(captcha_id, anything)
      end
    end
  end
end
