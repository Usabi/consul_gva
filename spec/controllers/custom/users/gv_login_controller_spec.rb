require "rails_helper"

describe Users::GvLoginController do
  let(:host) { "localhost" }
  let(:ip) { "127.0.0.1" }
  let(:cookie) { "f7aec2ad-4bd0-4520-9f03-c24995c276ae" }
  let(:api) { GVLoginApi.new(host) }

  let(:valid_body) do
    GVLoginApi::Response.new({
      "resultado": true,
      "datos": {
          "mail": "consulgva@gva.es",
          "roles": {
            "role": {
              "codigo": "PARTICIPEM_ADMIN"
            }
          },
          "nombre": "ConsulGVA",
          "infoAmpliada": {
            "parametro": []
          },
          "dni": "12345678A"
        }
      }.to_json)
  end

  let(:body_without_roles) do
    GVLoginApi::Response.new({
      "resultado": true,
      "datos": {
          "mail": "consulgva@gva.es",
          "roles": "",
          "nombre": "ConsulGVA",
          "infoAmpliada": {
            "parametro": []
          },
          "dni": "12345678A"
        }
      }.to_json)
  end

  let(:body_invalid_email) do
    GVLoginApi::Response.new({
      "resultado": true,
      "datos": {
          "mail": "Email",
          "roles": {
            "role": {
              "codigo": "PARTICIPEM_ADMIN"
            }
          },
          "nombre": "ConsulGVA",
          "infoAmpliada": {
            "parametro": []
          },
          "dni": "12345678A"
        }
      }.to_json)
  end

  let(:body_without_email) do
    GVLoginApi::Response.new({
      "resultado": true,
      "datos": {
          "roles": {
            "role": {
              "codigo": "PARTICIPEM_ADMIN"
            }
          },
          "nombre": "ConsulGVA",
          "infoAmpliada": {
            "parametro": []
          },
          "dni": "12345678A"
        }
      }.to_json)
  end

  describe "Create session by GVLogin API" do
    context "create new user" do
      before do
        request.headers["X-FORWARDED-FOR"] = ip
        request.headers["HOST"] = host
        cookies["gvlogin.login.GVLOGIN_COOKIE"] = cookie
      end

      it "request valid values" do
        expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(valid_body)
        get :login_or_redirect_to_sso
        user_created = User.last
        expect(user_created.username).to eq("ConsulGVA-GVLogin1")
        expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to eq(cookie)
        expect(flash[:success]).to eq(I18n.t("devise.sessions.signed_in"))
      end

      it "request without roles" do
        expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(body_without_roles)
        get :login_or_redirect_to_sso
        user_created = User.last
        expect(user_created.username).to eq("ConsulGVA-GVLogin1")
        expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be_nil
        expect(flash[:error]).to eq(I18n.t("devise.failure.no_backend_roles"))
      end

      it "request invalid email" do
        expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(body_invalid_email)
        get :login_or_redirect_to_sso
        user_created = User.last
        expect(user_created).to be_nil
        expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be_nil
        expect(flash[:error]).to eq("email: is invalid ('email')")
      end
      it "request without email" do
        expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(body_without_email)
        get :login_or_redirect_to_sso
        user_created = User.last
        expect(user_created).to be_nil
        expect(response.cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be_nil
        expect(flash[:error]).to eq("email: can't be blank ('')")
      end
    end

    context "update user" do
      before do
        u = User.new(
          username: "",
          email: "consulgva@.gva.es"
        )
        u.save!(validate: false)
        request.headers["X-FORWARDED-FOR"] = ip
        request.headers["HOST"] = host
        cookies["gvlogin.login.GVLOGIN_COOKIE"] = cookie
      end

      it "request valid values" do
        expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(valid_body)
        get :login_or_redirect_to_sso
        user_updated = User.last
        expect(user_updated.username).to eq("ConsulGVA-GVLogin1")
        expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to eq(cookie)
        expect(flash[:success]).to eq(I18n.t("devise.sessions.signed_in"))
      end

      it "request without roles" do
        expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(body_without_roles)
        get :login_or_redirect_to_sso
        user_updated = User.last
        expect(user_updated.username).to eq("ConsulGVA-GVLogin1")
        expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be_nil
        expect(flash[:error]).to eq(I18n.t("devise.failure.no_backend_roles"))
      end
    end
  end
end
