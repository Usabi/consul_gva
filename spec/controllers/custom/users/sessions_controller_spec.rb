require "rails_helper"

describe Users::SessionsController do
  before { request.env["devise.mapping"] = Devise.mappings[:user] }

  let!(:user) { create(:user, email: "citizen@consul.org", password: "12345678") }
  let(:captcha_id) { "TEST-CAPTCHA-ID-001" }

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
      allow(PttCaptchaApi).to receive(:crear).and_return(captcha_id)
      session[:ptt_captcha_id] = captcha_id
    end

    context "when captcha is valid" do
      before { allow(PttCaptchaApi).to receive(:validar).with(captcha_id, "1234").and_return(true) }

      it "signs in the user" do
        post :create, params: { user: { login: "citizen@consul.org", password: "12345678" },
                                ptt_valor_captcha: "1234" }
        expect(controller.current_user).to eq(user)
      end
    end

    context "when captcha is invalid" do
      before { allow(PttCaptchaApi).to receive(:validar).and_return(false) }

      it "does not sign in the user" do
        post :create, params: { user: { login: "citizen@consul.org", password: "12345678" },
                                ptt_valor_captcha: "wrong" }
        expect(controller.current_user).to be_nil
      end

      it "shows alert flash" do
        post :create, params: { user: { login: "citizen@consul.org", password: "12345678" },
                                ptt_valor_captcha: "wrong" }
        expect(flash[:alert]).to be_present
      end

      it "generates a new captcha for the re-render (old id replaced)" do
        new_captcha_id = "NEW-CAPTCHA-ID-002"
        allow(PttCaptchaApi).to receive(:crear).and_return(new_captcha_id)
        post :create, params: { user: { login: "citizen@consul.org", password: "12345678" },
                                ptt_valor_captcha: "wrong" }
        expect(session[:ptt_captcha_id]).to eq(new_captcha_id)
      end
    end

    context "when captcha id is missing from session" do
      before do
        session.delete(:ptt_captcha_id)
        allow(PttCaptchaApi).to receive(:validar).and_return(false)
      end

      it "blocks login even with any ptt_valor_captcha" do
        post :create, params: { user: { login: "citizen@consul.org", password: "12345678" },
                                ptt_valor_captcha: "1234" }
        expect(controller.current_user).to be_nil
      end
    end

    context "security: captcha id comes from session, not params" do
      it "validates against session id, ignoring any forged param" do
        allow(PttCaptchaApi).to receive(:validar).and_return(true)
        post :create, params: { user: { login: "citizen@consul.org", password: "12345678" },
                                ptt_valor_captcha: "1234",
                                ptt_captcha_id: "FORGED-ID" }
        expect(PttCaptchaApi).to have_received(:validar).with(captcha_id, anything)
      end
    end
  end

  describe "Google reCAPTCHA fallback" do
    before { allow(Rails.application.secrets).to receive(:ptt_app_id).and_return("") }

    context "when site_key and secret_key are configured" do
      before do
        allow(Rails.application.secrets).to receive(:site_key).and_return("SITE-KEY")
        allow(Rails.application.secrets).to receive(:secret_key).and_return("SECRET-KEY")
      end

      it "does not request a PTT captcha on #new" do
        expect(PttCaptchaApi).not_to receive(:crear)
        get :new
      end

      it "signs in the user when the recaptcha verification succeeds" do
        allow(controller).to receive(:verify_recaptcha).and_return(true)
        post :create, params: { user: { login: "citizen@consul.org", password: "12345678" } }
        expect(controller.current_user).to eq(user)
      end

      it "does not sign in the user when the recaptcha verification fails" do
        allow(controller).to receive(:verify_recaptcha).and_return(false)
        post :create, params: { user: { login: "citizen@consul.org", password: "12345678" } }
        expect(controller.current_user).to be_nil
        expect(flash[:alert]).to be_present
      end
    end

    context "when neither PTT nor Google secrets are configured" do
      before do
        allow(Rails.application.secrets).to receive(:site_key).and_return("")
        allow(Rails.application.secrets).to receive(:secret_key).and_return("")
      end

      it "does not request a PTT captcha on #new" do
        expect(PttCaptchaApi).not_to receive(:crear)
        get :new
      end

      it "signs in the user without any captcha check" do
        post :create, params: { user: { login: "citizen@consul.org", password: "12345678" } }
        expect(controller.current_user).to eq(user)
      end

      it "does not render any captcha widget", render_views: true do
        get :new
        expect(response.body).not_to include("data-captcha-id")
        expect(response.body).not_to include("g-recaptcha")
      end
    end
  end
end
