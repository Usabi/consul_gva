require "rails_helper"

describe Users::GvLoginController do
  let(:host) { "localhost" }
  let(:ip) { "127.0.0.1" }
  let(:cookie) { "f7aec2ad-4bd0-4520-9f03-c24995c276ae" }
  let(:api) { GvLoginApi.new(host) }
  let(:data) do
    OpenStruct.new({
      name: "Consul",
      email: "consulgva@gva.es",
      codper: "12345678",
      dni: "12345678A"
    })
  end
  let(:valid_vmcrc_user) do
    build(:vmcrc_persona, nomb: data.name, dni: data.dni, dcorreoint: data.email, codper: data.codper)
  end
  let(:invalid_vmcrc_user) do
    build(:vmcrc_persona, nomb: data.name, dni: data.dni, dcorreoint: "", codper: "")
  end

  let(:valid_body) do
    GvLoginApi::Response.new({
      resultado: true,
      datos: {
        mail: data.email,
        roles: {
          role: {
            codigo: "PARTICIPEM_CON",
            parametros: {
              parametro: {
                valorParametro: "R_MODERA",
                nombreParametro: "ROL"
              }
            }
          }
        },
        nombre: data.name,
        infoAmpliada: {
          parametro: [
            {
              valorParametro: data.codper,
              nombreParametro: "codper"
            }
          ]
        },
        dni: data.dni
      }
    }.to_json)
  end

  let(:body_without_roles) do
    GvLoginApi::Response.new({
      resultado: true,
      datos: {
        mail: data.email,
        roles: "",
        nombre: data.name,
        infoAmpliada: {
          parametro: [
            {
              valorParametro: data.codper,
              nombreParametro: "codper"
            }
          ]
        },
        dni: data.dni
      }
    }.to_json)
  end

  let(:body_invalid_email) do
    GvLoginApi::Response.new({
      resultado: true,
      datos: {
        mail: "Email",
        roles: {
          role: {
            codigo: "PARTICIPEM_CON",
            parametros: {
              parametro: {
                valorParametro: "R_MODERA",
                nombreParametro: "ROL"
              }
            }
          }
        },
        nombre: data.name,
        infoAmpliada: {
          parametro: [
            {
              valorParametro: data.codper,
              nombreParametro: "codper"
            }
          ]
        },
        dni: data.dni
      }
    }.to_json)
  end

  let(:body_not_gva_email) do
    GvLoginApi::Response.new({
      resultado: true,
      datos: {
        mail: "test@test.com",
        roles: {
          role: {
            codigo: "PARTICIPEM_CON",
            parametros: {
              parametro: {
                valorParametro: "R_MODERA",
                nombreParametro: "ROL"
              }
            }
          }
        },
        nombre: data.name,
        infoAmpliada: {
          parametro: [
            {
              valorParametro: data.codper,
              nombreParametro: "codper"
            }
          ]
        },
        dni: data.dni
      }
    }.to_json)
  end

  let(:body_without_email) do
    GvLoginApi::Response.new({
      resultado: true,
      datos: {
        roles: {
          role: {
            codigo: "PARTICIPEM_CON",
            parametros: {
              parametro: {
                valorParametro: "R_MODERA",
                nombreParametro: "ROL"
              }
            }
          }
        },
        nombre: data.name,
        infoAmpliada: {
          parametro: [
            {
              valorParametro: data.codper,
              nombreParametro: "codper"
            }
          ]
        },
        dni: data.dni
      }
    }.to_json)
  end

  let(:body_blank_email) do
    GvLoginApi::Response.new({
      resultado: true,
      datos: {
        mail: "",
        roles: {
          role: {
            codigo: "PARTICIPEM_CON",
            parametros: {
              parametro: {
                valorParametro: "R_MODERA",
                nombreParametro: "ROL"
              }
            }
          }
        },
        nombre: data.name,
        infoAmpliada: {
          parametro: [
            {
              valorParametro: data.codper,
              nombreParametro: "codper"
            }
          ]
        },
        dni: data.dni
      }
    }.to_json)
  end

  let(:body_without_codper) do
    GvLoginApi::Response.new({
      resultado: true,
      datos: {
        mail: data.email,
        roles: {
          role: {
            codigo: "PARTICIPEM_CON",
            parametros: {
              parametro: {
                valorParametro: "R_MODERA",
                nombreParametro: "ROL"
              }
            }
          }
        },
        nombre: data.name,
        infoAmpliada: {
          parametro: []
        },
        dni: data.dni
      }
    }.to_json)
  end

  let(:body_invalid_codper) do
    GvLoginApi::Response.new({
      resultado: true,
      datos: {
        mail: data.email,
        roles: {
          role: {
            codigo: "PARTICIPEM_CON",
            parametros: {
              parametro: {
                valorParametro: "R_MODERA",
                nombreParametro: "ROL"
              }
            }
          }
        },
        nombre: data.name,
        infoAmpliada: {
          parametro: [
            {
              valorParametro: "",
              nombreParametro: "codper"
            }
          ]
        },
        dni: data.dni
      }
    }.to_json)
  end

  let(:body_invalid_email_codper) do
    GvLoginApi::Response.new({
      resultado: true,
      datos: {
        mail: "test@test.com",
        roles: {
          role: {
            codigo: "PARTICIPEM_CON",
            parametros: {
              parametro: {
                valorParametro: "R_MODERA",
                nombreParametro: "ROL"
              }
            }
          }
        },
        nombre: data.name,
        infoAmpliada: {
          parametro: [
            {
              valorParametro: "",
              nombreParametro: "codper"
            }
          ]
        },
        dni: data.dni
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
          expect_any_instance_of(GvLoginApi).to receive(:context).with(ip, cookie).and_return(valid_body)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"]).user

          expect(user_created.name).to eq("#{data.name}-GVLogin1")
          expect(identity_user.name).to eq("#{data.name}-GVLogin1")

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to eq(cookie)
          expect(flash[:success]).to eq(I18n.t("devise.sessions.signed_in"))
        end

        it "request without roles" do
          expect_any_instance_of(GvLoginApi).to receive(:context).with(ip,
                                                                       cookie).and_return(body_without_roles)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"]).user

          expect(user_created.name).to eq("#{data.name}-GVLogin1")
          expect(identity_user.name).to eq("#{data.name}-GVLogin1")

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be(nil)
          expect(flash[:error]).to eq(I18n.t("devise.failure.default"))
        end

        it "request invalid email" do
          expect_any_instance_of(GvLoginApi).to receive(:context).with(ip,
                                                                       cookie).and_return(body_invalid_email)
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
          expect_any_instance_of(GvLoginApi).to receive(:context).with(ip,
                                                                       cookie).and_return(body_not_gva_email)
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
          expect_any_instance_of(GvLoginApi).to receive(:context).with(ip,
                                                                       cookie).and_return(body_without_email)
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
          expect_any_instance_of(GvLoginApi).to receive(:context).with(ip,
                                                                       cookie).and_return(body_blank_email)
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
          expect_any_instance_of(GvLoginApi).to receive(:context).with(ip,
                                                                       cookie).and_return(body_invalid_codper)
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
          expect_any_instance_of(GvLoginApi).to receive(:context).with(ip,
                                                                       cookie).and_return(body_without_codper)
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
          expect_any_instance_of(GvLoginApi).to receive(:context).with(ip,
                                                                       cookie).and_return(body_invalid_email_codper)
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
          expect_any_instance_of(GvLoginApi).to receive(:context).with(ip,
                                                                       cookie).and_return(body_invalid_email)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"])

          expect(user_created).to be(nil)
          expect(identity_user).to be(nil)

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be(nil)
          expect(flash[:error]).to eq(I18n.t("devise.failure.default"))
        end

        it "request not gva email" do
          expect_any_instance_of(GvLoginApi).to receive(:context).with(ip,
                                                                       cookie).and_return(body_not_gva_email)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"])

          expect(user_created).to be(nil)
          expect(identity_user).to be(nil)

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be(nil)
          expect(flash[:error]).to eq(I18n.t("devise.failure.default"))
        end

        it "request without email" do
          expect_any_instance_of(GvLoginApi).to receive(:context).with(ip,
                                                                       cookie).and_return(body_without_email)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"])

          expect(user_created).to be(nil)
          expect(identity_user).to be(nil)

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be(nil)
          expect(flash[:error]).to eq(I18n.t("devise.failure.default"))
        end

        it "request blank email" do
          expect_any_instance_of(GvLoginApi).to receive(:context).with(ip,
                                                                       cookie).and_return(body_blank_email)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"])

          expect(user_created).to be(nil)
          expect(identity_user).to be(nil)

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be(nil)
          expect(flash[:error]).to eq(I18n.t("devise.failure.default"))
        end

        it "request invalid codper" do
          expect_any_instance_of(GvLoginApi).to receive(:context).with(ip,
                                                                       cookie).and_return(body_invalid_codper)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"])

          expect(user_created).to be(nil)
          expect(identity_user).to be(nil)

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be(nil)
          expect(flash[:error]).to eq(I18n.t("devise.failure.default"))
        end

        it "request without codper" do
          expect_any_instance_of(GvLoginApi).to receive(:context).with(ip,
                                                                       cookie).and_return(body_without_codper)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"])

          expect(user_created).to be(nil)
          expect(identity_user).to be(nil)

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be(nil)
          expect(flash[:error]).to eq(I18n.t("devise.failure.default"))
        end

        it "request invalid codper and email" do
          expect_any_instance_of(GvLoginApi).to receive(:context).with(ip,
                                                                       cookie).and_return(body_invalid_email_codper)
          get :login_or_redirect_to_sso
          user_created = User.last
          identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"])

          expect(user_created).to be(nil)
          expect(identity_user).to be(nil)

          expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be(nil)
          expect(flash[:error]).to eq(I18n.t("devise.failure.default"))
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
        expect_any_instance_of(GvLoginApi).to receive(:context).with(ip, cookie).and_return(valid_body)
        get :login_or_redirect_to_sso
        user_updated = User.last
        identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"]).user

        expect(user_updated.name).to eq("#{data.name}-GVLogin1")
        expect(identity_user.name).to eq("#{data.name}-GVLogin1")
        expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to eq(cookie)
        expect(flash[:success]).to eq(I18n.t("devise.sessions.signed_in"))
      end

      it "request without roles" do
        expect_any_instance_of(GvLoginApi).to receive(:context).with(ip,
                                                                     cookie).and_return(body_without_roles)
        get :login_or_redirect_to_sso
        user_updated = User.last
        identity_user = Identity.find_by(uid: valid_body.data.info_ampliada["codper"]).user

        expect(user_updated.name).to eq("#{data.name}-GVLogin1")
        expect(identity_user.name).to eq("#{data.name}-GVLogin1")
        expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be(nil)
        expect(flash[:error]).to eq(I18n.t("devise.failure.default"))
      end
    end
  end

  describe "Create session by GVLogin API" do # rubocop:disable RSpec/RepeatedExampleGroupDescription
    context "create new user" do
      before do
        request.headers["X-FORWARDED-FOR"] = ip
        request.headers["HOST"] = host
        cookies["gvlogin.login.GVLOGIN_COOKIE"] = cookie
      end

      context "valid vmcrc_user" do
        before { valid_vmcrc_user.save }

        describe "role assignment" do
          it "assigns only MODERATOR role when R_MODERA is received" do
            resp = gvlogin_response_with_roles("R_MODERA")
            expect_any_instance_of(GvLoginApi).to receive(:context).with(ip, cookie).and_return(resp)

            get :login_or_redirect_to_sso

            user = Identity.find_by(uid: data.codper).user

            expect(user.moderator?).to be true
            expect(user.administrator?).to be false
            expect(user.official?).to be false
            expect(user.valuator?).to be false
            expect(user.manager?).to be false
            expect(user.sdg_manager?).to be false
            expect(user.legislator?).to be false
            expect(user.budget_manager?).to be false
            expect(user.supporter?).to be false

            expect(flash[:success]).to eq(I18n.t("devise.sessions.signed_in"))
            expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to eq(cookie)
          end

          it "assigns ADMIN role when R_ADMIN is received" do
            resp = gvlogin_response_with_roles("R_ADMIN")
            expect_any_instance_of(GvLoginApi).to receive(:context).with(ip, cookie).and_return(resp)

            get :login_or_redirect_to_sso

            user = Identity.find_by(uid: data.codper).user

            expect(user.administrator?).to be true
            expect(user.moderator?).to be false

            expect(flash[:success]).to eq(I18n.t("devise.sessions.signed_in"))
          end

          it "assigns multiple roles when an array of roles is received" do
            resp = gvlogin_response_with_roles(%w[R_MODERA R_ODS])
            expect_any_instance_of(GvLoginApi).to receive(:context).with(ip, cookie).and_return(resp)

            get :login_or_redirect_to_sso

            user = Identity.find_by(uid: data.codper).user

            expect(user.moderator?).to be true
            expect(user.sdg_manager?).to be true
            expect(user.administrator?).to be false
            expect(user.manager?).to be false
            expect(user.legislator?).to be false
            expect(user.budget_manager?).to be false
            expect(user.supporter?).to be false

            expect(flash[:success]).to eq(I18n.t("devise.sessions.signed_in"))
          end

          it "replaces previous roles based on incoming roles (single login)" do
            # Creamos un usuario existente con rol MODERATOR y su identidad GVLogin (uid = codper)
            user = User.new(username: "", email: "consulgva@gva.es")
            user.save!(validate: false)
            user.create_moderator # estado inicial

            auth = OpenStruct.new(uid: data.codper, provider: :gvlogin)
            identity = Identity.first_or_create_from_oauth(auth)
            identity.update!(user: user)

            # Preparamos headers/cookie y la respuesta con el NUEVO rol (R_SOPORTE)
            request.headers["X-FORWARDED-FOR"] = ip
            request.headers["HOST"] = host
            cookies["gvlogin.login.GVLOGIN_COOKIE"] = cookie

            resp_new_role = gvlogin_response_with_roles("R_SOPORTE")
            expect_any_instance_of(GvLoginApi).to receive(:context).with(ip, cookie).and_return(resp_new_role)

            # Un único login
            get :login_or_redirect_to_sso

            user.reload
            # Debe quitar MODERATOR y poner SUPPORTER
            expect(user.supporter?).to be true
            expect(user.moderator?).to be false

            expect(flash[:success]).to eq(I18n.t("devise.sessions.signed_in"))
            expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to eq(cookie)
          end

          it "rejects login when role is invalid" do
            resp = gvlogin_response_with_roles("ROL_INEXISTENTE")
            expect_any_instance_of(GvLoginApi).to receive(:context).with(ip, cookie).and_return(resp)

            get :login_or_redirect_to_sso

            user = Identity.find_by(uid: data.codper)&.user
            expect(user.moderator?).to be false
            expect(user.sdg_manager?).to be false
            expect(user.administrator?).to be false
            expect(user.manager?).to be false
            expect(user.legislator?).to be false
            expect(user.budget_manager?).to be false
            expect(user.supporter?).to be false

            expect(cookies["gvlogin.login.GVLOGIN_COOKIE"]).to be(nil)
            expect(flash[:error]).to eq(I18n.t("devise.failure.default"))
          end
        end
      end
    end
  end
end
