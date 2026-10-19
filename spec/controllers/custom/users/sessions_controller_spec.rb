require "rails_helper"

describe Users::SessionsController do
  before { request.env["devise.mapping"] = Devise.mappings[:user] }

  let!(:user) { create(:user, email: "citizen@consul.org", password: "12345678") }
  let(:captcha_id) { "TEST-CAPTCHA-ID-001" }

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

    context "when the first attempt to create the captcha fails" do
      it "retries once and stores the id so the widget does not disappear" do
        allow(PttCaptchaApi).to receive(:create_captcha).and_return(nil, captcha_id)

        get :new

        expect(session[:ptt_captcha_id]).to eq(captcha_id)
      end

      it "gives up after the retry" do
        allow(PttCaptchaApi).to receive(:create_captcha).and_return(nil)

        get :new

        expect(PttCaptchaApi).to have_received(:create_captcha).twice
        expect(session[:ptt_captcha_id]).to be_nil
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
      allow(PttCaptchaApi).to receive(:create_captcha).and_return(captcha_id)
      session[:ptt_captcha_id] = captcha_id
    end

    context "when captcha is valid" do
      before { allow(PttCaptchaApi).to receive(:validate_captcha).with(captcha_id, "1234").and_return(true) }

      it "signs in the user" do
        post :create, params: { user: { login: "citizen@consul.org", password: "12345678" },
                                ptt_valor_captcha: "1234" }
        expect(controller.current_user).to eq(user)
      end
    end

    context "when captcha is invalid" do
      before { allow(PttCaptchaApi).to receive(:validate_captcha).and_return(false) }

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
        allow(PttCaptchaApi).to receive(:create_captcha).and_return(new_captcha_id)
        post :create, params: { user: { login: "citizen@consul.org", password: "12345678" },
                                ptt_valor_captcha: "wrong" }
        expect(session[:ptt_captcha_id]).to eq(new_captcha_id)
      end
    end

    context "when captcha id is missing from session" do
      before do
        session.delete(:ptt_captcha_id)
        allow(PttCaptchaApi).to receive(:validate_captcha).and_return(false)
      end

      it "blocks login even with any ptt_valor_captcha" do
        post :create, params: { user: { login: "citizen@consul.org", password: "12345678" },
                                ptt_valor_captcha: "1234" }
        expect(controller.current_user).to be_nil
      end
    end

    context "security: captcha id comes from session, not params" do
      it "validates against session id, ignoring any forged param" do
        allow(PttCaptchaApi).to receive(:validate_captcha).and_return(true)
        post :create, params: { user: { login: "citizen@consul.org", password: "12345678" },
                                ptt_valor_captcha: "1234",
                                ptt_captcha_id: "FORGED-ID" }
        expect(PttCaptchaApi).to have_received(:validate_captcha).with(captcha_id, anything)
      end
    end
  end

  describe "Google reCAPTCHA fallback" do
    before { allow(PttCaptcha.configuration).to receive(:app_id).and_return("") }

    context "when site_key and secret_key are configured" do
      before do
        allow(Rails.application.secrets).to receive(:site_key).and_return("SITE-KEY")
        allow(Rails.application.secrets).to receive(:secret_key).and_return("SECRET-KEY")
      end

      it "does not request a PTT captcha on #new" do
        expect(PttCaptchaApi).not_to receive(:create_captcha)
        get :new
      end

      it "signs in the user when the recaptcha verification succeeds" do
        allow(controller).to receive(:verify_recaptcha).and_return(true)
        post :create, params: { user: { login: "citizen@consul.org", password: "12345678" }}
        expect(controller.current_user).to eq(user)
      end

      it "does not sign in the user when the recaptcha verification fails" do
        allow(controller).to receive(:verify_recaptcha).and_return(false)
        post :create, params: { user: { login: "citizen@consul.org", password: "12345678" }}
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
        expect(PttCaptchaApi).not_to receive(:create_captcha)
        get :new
      end

      it "signs in the user without any captcha check" do
        post :create, params: { user: { login: "citizen@consul.org", password: "12345678" }}
        expect(controller.current_user).to eq(user)
      end

      it "does not render any captcha widget", render_views: true do
        get :new
        expect(response.body).not_to include("data-captcha-id")
        expect(response.body).not_to include("g-recaptcha")
      end
    end
  end

  describe "Google reCAPTCHA fallback when PTT is configured but unavailable" do
    before do
      allow(PttCaptchaApi).to receive(:create_captcha).and_return(nil)
      allow(Rails.application.secrets).to receive_messages(site_key: "SITE-KEY", secret_key: "SECRET-KEY")
    end

    it "does not store a PTT captcha id on #new" do
      get :new

      expect(session[:ptt_captcha_id]).to be_nil
    end

    it "renders the Google widget instead of the PTT one on #new", render_views: true do
      get :new

      expect(response.body).not_to include("data-captcha-id")
    end

    it "validates with Google when PTT could not be created on #new" do
      get :new
      allow(controller).to receive(:verify_recaptcha).and_return(true)

      post :create, params: { user: { login: "citizen@consul.org", password: "12345678" }}

      expect(controller.current_user == user).to be_truthy
    end

    it "does not use PTT validation once the fallback is active" do
      get :new
      allow(controller).to receive(:verify_recaptcha).and_return(true)
      allow(PttCaptchaApi).to receive(:validate_captcha)

      post :create, params: { user: { login: "citizen@consul.org", password: "12345678" }}

      expect(PttCaptchaApi).not_to have_received(:validate_captcha)
    end

    it "still blocks when Google verification fails" do
      get :new
      allow(controller).to receive(:verify_recaptcha).and_return(false)

      post :create, params: { user: { login: "citizen@consul.org", password: "12345678" }}

      expect(controller.current_user.nil?).to be_truthy
    end

    it "fails closed when the request did not go through #new (no fallback flag in session)" do
      allow(controller).to receive(:verify_recaptcha).and_return(true)
      allow(PttCaptchaApi).to receive(:validate_captcha).and_return(false)

      post :create, params: { user: { login: "citizen@consul.org", password: "12345678" }}

      expect(controller.current_user.nil?).to be_truthy
    end

    it "fails closed when Google is not configured either" do
      allow(Rails.application.secrets).to receive_messages(site_key: "", secret_key: "")
      get :new
      allow(PttCaptchaApi).to receive(:validate_captcha).and_return(false)

      post :create, params: { user: { login: "citizen@consul.org", password: "12345678" }}

      expect(controller.current_user.nil?).to be_truthy
    end

    it "goes back to PTT when the captcha can be created again" do
      get :new
      allow(PttCaptchaApi).to receive(:create_captcha).and_return("NEW-ID")

      get :new

      expect(session[:ptt_captcha_id]).to eq("NEW-ID")
    end
  end
end
