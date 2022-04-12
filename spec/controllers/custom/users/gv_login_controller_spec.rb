require "rails_helper"

describe Users::GvLoginController do
  let(:host) { "localhost" }
  let(:ip) { "127.0.0.1" }
  let(:cookie) { "f7aec2ad-4bd0-4520-9f03-c24995c276ae" }
  let(:api) { GVLoginApi.new(host) }
  let(:data) do
    OpenStruct.new({
      name: "Consul",
      email: "consulgva@gva.es",
      codper: "12345678",
      dni: "12345678A"
    })
  end
  let(:valid_vmcrc_user) { build(:vmcrc_persona, nomb: data.name, dni: data.dni, dcorreo: data.email, codper: data.codper) }
  let(:invalid_vmcrc_user) { build(:vmcrc_persona, nomb: data.name, dni: data.dni, dcorreo: "", codper: "") }
  let(:valid_body) do
    GVLoginApi::Response.new({
      "resultado": true,
      "datos": {
          "mail": data.email,
          "roles": {
            "role": {
              "codigo": "PARTICIPEM_ADMIN"
            }
          },
          "nombre": data.name,
          "infoAmpliada": {
            "parametro": [
                {
                  "valorParametro": data.codper,
                  "nombreParametro": "codper"
                }
            ]
          },
          "dni": data.dni
        }
      }.to_json)
  end

  let(:body_without_roles) do
    GVLoginApi::Response.new({
      "resultado": true,
      "datos": {
          "mail": data.email,
          "roles": "",
          "nombre": data.name,
          "infoAmpliada": {
            "parametro": [
                {
                  "valorParametro": data.codper,
                  "nombreParametro": "codper"
                }
            ]
          },
          "dni": data.dni
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
          "nombre": data.name,
          "infoAmpliada": {
            "parametro": [
              {
                "valorParametro": data.codper,
                "nombreParametro": "codper"
              }
          ]
          },
          "dni": data.dni
        }
      }.to_json)
  end

  let(:body_not_gva_email) do
    GVLoginApi::Response.new({
      "resultado": true,
      "datos": {
          "mail": "test@test.com",
          "roles": {
            "role": {
              "codigo": "PARTICIPEM_ADMIN"
            }
          },
          "nombre": data.name,
          "infoAmpliada": {
            "parametro": [
              {
                "valorParametro": data.codper,
                "nombreParametro": "codper"
              }
          ]
          },
          "dni": data.dni
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
          "nombre": data.name,
          "infoAmpliada": {
            "parametro": [
                {
                  "valorParametro": data.codper,
                  "nombreParametro": "codper"
                }
            ]
          },
          "dni": data.dni
        }
      }.to_json)
  end

  let(:body_blank_email) do
    GVLoginApi::Response.new({
      "resultado": true,
      "datos": {
          "mail": "",
          "roles": {
            "role": {
              "codigo": "PARTICIPEM_ADMIN"
            }
          },
          "nombre": data.name,
          "infoAmpliada": {
            "parametro": [
                {
                  "valorParametro": data.codper,
                  "nombreParametro": "codper"
                }
            ]
          },
          "dni": data.dni
        }
      }.to_json)
  end

  let(:body_without_codper) do
    GVLoginApi::Response.new({
      "resultado": true,
      "datos": {
          "mail": data.email,
          "roles": {
            "role": {
              "codigo": "PARTICIPEM_ADMIN"
            }
          },
          "nombre": data.name,
          "infoAmpliada": {
            "parametro": []
          },
          "dni": data.dni
        }
      }.to_json)
  end

  let(:body_invalid_codper) do
    GVLoginApi::Response.new({
      "resultado": true,
      "datos": {
          "mail": data.email,
          "roles": {
            "role": {
              "codigo": "PARTICIPEM_ADMIN"
            }
          },
          "nombre": data.name,
          "infoAmpliada": {
            "parametro": [
                {
                  "valorParametro": "",
                  "nombreParametro": "codper"
                }
            ]
          },
          "dni": data.dni
        }
      }.to_json)
  end

  let(:body_invalid_email_codper) do
    GVLoginApi::Response.new({
      "resultado": true,
      "datos": {
          "mail": "test@test.com",
          "roles": {
            "role": {
              "codigo": "PARTICIPEM_ADMIN"
            }
          },
          "nombre": data.name,
          "infoAmpliada": {
            "parametro": [
                {
                  "valorParametro": "",
                  "nombreParametro": "codper"
                }
            ]
          },
          "dni": data.dni
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

      context "valid vmcrc_user" do
        before do
          valid_vmcrc_user.save
        end
        it "request valid values" do
          expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(valid_body)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"]).user

          expect(user_created.name).to eq("#{data.name}-GVLogin1")
          expect(identity_user.name).to eq("#{data.name}-GVLogin1")

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to eq(cookie)
          expect(flash[:success]).to eq(I18n.t("devise.sessions.signed_in"))
        end

        it "request without roles" do
          expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(body_without_roles)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"]).user

          expect(user_created.name).to eq("#{data.name}-GVLogin1")
          expect(identity_user.name).to eq("#{data.name}-GVLogin1")

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be_nil
          expect(flash[:error]).to eq(I18n.t("devise.failure.no_backend_roles"))
        end

        it "request invalid email" do
          expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(body_invalid_email)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"]).user

          expect(user_created.name).to eq("#{data.name}-GVLogin1")
          expect(identity_user.name).to eq("#{data.name}-GVLogin1")
          expect(user_created.email).to eq(data.email)
          expect(identity_user.email).to eq(data.email)

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to eq(cookie)
          expect(flash[:success]).to eq(I18n.t("devise.sessions.signed_in"))
        end

        it "request not gva email" do
          expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(body_not_gva_email)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"]).user

          expect(user_created.name).to eq("#{data.name}-GVLogin1")
          expect(identity_user.name).to eq("#{data.name}-GVLogin1")

          expect(user_created.email).to eq(data.email)
          expect(identity_user.email).to eq(data.email)

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to eq(cookie)
          expect(flash[:success]).to eq(I18n.t("devise.sessions.signed_in"))
        end

        it "request without email" do
          expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(body_without_email)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"]).user

          expect(user_created.name).to eq("#{data.name}-GVLogin1")
          expect(identity_user.name).to eq("#{data.name}-GVLogin1")

          expect(user_created.email).to eq(data.email)
          expect(identity_user.email).to eq(data.email)

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to eq(cookie)
          expect(flash[:success]).to eq(I18n.t("devise.sessions.signed_in"))
        end

        it "request blank email" do
          expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(body_blank_email)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"]).user

          expect(user_created.name).to eq("#{data.name}-GVLogin1")
          expect(identity_user.name).to eq("#{data.name}-GVLogin1")

          expect(user_created.email).to eq(data.email)
          expect(identity_user.email).to eq(data.email)

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to eq(cookie)
          expect(flash[:success]).to eq(I18n.t("devise.sessions.signed_in"))
        end

        it "request invalid codper" do
          expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(body_invalid_codper)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"]).user

          expect(user_created.name).to eq("#{data.name}-GVLogin1")
          expect(identity_user.name).to eq("#{data.name}-GVLogin1")

          expect(user_created.email).to eq(data.email)
          expect(identity_user.email).to eq(data.email)

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to eq(cookie)
          expect(flash[:success]).to eq(I18n.t("devise.sessions.signed_in"))
        end

        it "request without codper" do
          expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(body_without_codper)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"]).user

          expect(user_created.name).to eq("#{data.name}-GVLogin1")
          expect(identity_user.name).to eq("#{data.name}-GVLogin1")

          expect(user_created.email).to eq(data.email)
          expect(identity_user.email).to eq(data.email)

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to eq(cookie)
          expect(flash[:success]).to eq(I18n.t("devise.sessions.signed_in"))
        end

        it "request invalid codper and email" do
          expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(body_invalid_email_codper)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"]).user

          expect(user_created.name).to eq("#{data.name}-GVLogin1")
          expect(identity_user.name).to eq("#{data.name}-GVLogin1")

          expect(user_created.email).to eq(data.email)
          expect(identity_user.email).to eq(data.email)

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to eq(cookie)
          expect(flash[:success]).to eq(I18n.t("devise.sessions.signed_in"))
        end

      end

      context "invalid vmcrc_user" do
        before do
          invalid_vmcrc_user.save
        end

        it "request invalid email" do
          expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(body_invalid_email)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"])

          expect(user_created).to be_nil
          expect(identity_user).to be_nil

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be_nil
          expect(flash[:error]).to eq(I18n.t("devise.failure.no_codeper_email"))
        end

        it "request not gva email" do
          expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(body_not_gva_email)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"])

          expect(user_created).to be_nil
          expect(identity_user).to be_nil

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be_nil
          expect(flash[:error]).to eq(I18n.t("devise.failure.no_codeper_email"))
        end

        it "request without email" do
          expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(body_without_email)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"])

          expect(user_created).to be_nil
          expect(identity_user).to be_nil

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be_nil
          expect(flash[:error]).to eq(I18n.t("devise.failure.no_codeper_email"))
        end

        it "request blank email" do
          expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(body_blank_email)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"])

          expect(user_created).to be_nil
          expect(identity_user).to be_nil

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be_nil
          expect(flash[:error]).to eq(I18n.t("devise.failure.no_codeper_email"))
        end

        it "request invalid codper" do
          expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(body_invalid_codper)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"])

          expect(user_created).to be_nil
          expect(identity_user).to be_nil

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be_nil
          expect(flash[:error]).to eq(I18n.t("devise.failure.no_codeper_email"))
        end

        it "request without codper" do
          expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(body_without_codper)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"])

          expect(user_created).to be_nil
          expect(identity_user).to be_nil

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be_nil
          expect(flash[:error]).to eq(I18n.t("devise.failure.no_codeper_email"))
        end

        it "request invalid codper and email" do
          expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(body_invalid_email_codper)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"])

          expect(user_created).to be_nil
          expect(identity_user).to be_nil

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be_nil
          expect(flash[:error]).to eq(I18n.t("devise.failure.no_codeper_email"))
        end
      end

    end

    context "update user" do
      before do
        user = User.new(
          username: "",
          email: "consulgva@.gva.es"
        )
        user.save!(validate: false)
        auth = OpenStruct.new(uid: "12345678", provider: :gvlogin)
        identity = Identity.first_or_create_from_oauth(auth)
        identity.update!(user: user)
        request.headers["X-FORWARDED-FOR"] = ip
        request.headers["HOST"] = host
        cookies["gvlogin.login.GVLOGIN_COOKIE"] = cookie
      end

      it "request valid values" do
        expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(valid_body)
        get :login_or_redirect_to_sso
        user_updated = User.last
        identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"]).user

        expect(user_updated.name).to eq("#{data.name}-GVLogin1")
        expect(identity_user.name).to eq("#{data.name}-GVLogin1")
        expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to eq(cookie)
        expect(flash[:success]).to eq(I18n.t("devise.sessions.signed_in"))
      end

      it "request without roles" do
        expect_any_instance_of(GVLoginApi).to receive(:context).with(ip, cookie).and_return(body_without_roles)
        get :login_or_redirect_to_sso
        user_updated = User.last
        identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"]).user

        expect(user_updated.name).to eq("#{data.name}-GVLogin1")
        expect(identity_user.name).to eq("#{data.name}-GVLogin1")
        expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be_nil
        expect(flash[:error]).to eq(I18n.t("devise.failure.no_backend_roles"))
      end
    end
  end
end
