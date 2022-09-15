class Users::GvLoginController < ApplicationController
  skip_authorization_check :login_or_redirect_to_sso

  GVA_ROLES = {
    "R_ADMIN" => :administrator,
    "R_ASOCI" => :organization,
    "R_CARGO" => :official,
    "R_MODERA" => :moderator,
    "R_EVALUA" => :valuator,
    "R_GESTOR" => :manager,
    "R_ODS" => :sdg_manager,
    "R_LEGISLA" => :legislator,
    "R_PRESUPUESTO" => :budget_manager
  }.freeze

  def login_or_redirect_to_sso
    remote_ip = request.x_forwarded_for
    cookie = cookies["gvlogin.login.GVLOGIN_COOKIE"]
    gvlogin_api = GVLoginApi.new(request.host)

    if cookie
      begin
        check_context = gvlogin_api.context(remote_ip, cookie)
        if check_context.valid?
          sign_in_gvlogin(check_context.data)
        else
          flash[:error] = check_context.errors
          redirect_to gvlogin_api.web_gv_login
        end
      rescue JSON::ParserError
        flash[:error] = "Ocurrio error en el servidor"
        redirect_to gvlogin_api.web_gv_login
      rescue PG::UndefinedTable
        flash[:error] = "Ocurrio error en la base de datos"
        redirect_to gvlogin_api.web_gv_login
      end
    else
      redirect_to gvlogin_api.web_gv_login
    end
  end

  def after_sign_in_path_for(resource)
    root_path
  end

  private

    def sign_in_gvlogin(data)
      if (uid = data.info_ampliada["codper"].presence) && isEmailGVA?(data.mail)
        # Add guide connection codper
        auth = OpenStruct.new(uid: uid, provider: :gvlogin)
        identity = Identity.first_or_create_from_oauth(auth)
      else
        if isEmailGVA?(data.mail)
          vmcrc_user = VmcrcPersona.find_by(dni: data.dni)
          unless vmcrc_user&.codper.present?
            error_user_data
            return
          end
          auth = OpenStruct.new(uid: vmcrc_user.codper, provider: :gvlogin)
          identity = Identity.first_or_create_from_oauth(auth)
        elsif (uid = data.info_ampliada["codper"].presence)
          vmcrc_user = VmcrcPersona.find_by(codper: uid)
          unless vmcrc_user&.dcorreoint.present?
            error_user_data
            return
          end
          auth = OpenStruct.new(uid: uid, provider: :gvlogin)
          identity = Identity.first_or_create_from_oauth(auth)
          data.mail = vmcrc_user.dcorreoint
        else
          vmcrc_user = VmcrcPersona.find_by(dni: data.dni)
          unless vmcrc_user&.dcorreoint.present? && vmcrc_user&.codper.present?
            error_user_data
            return
          end
          auth = OpenStruct.new(uid: vmcrc_user.codper, provider: :gvlogin)
          identity = Identity.first_or_create_from_oauth(auth)
          data.mail = vmcrc_user.dcorreoint
        end
      end
      @user = get_or_create_user(data, identity)

      identity.update!(user: @user)
      save_user(data)
    end

    def isEmailGVA?(email)
      email.present? ? (email.include? "gva.es") : false
    end

    def delete_cookies
      cookies.delete("gvlogin.login.GVLOGIN_COOKIE", domain: request.domain)
    end

    def get_or_create_user(data, identity)
      user = identity.user&.valid? ? identity.user : User.first_or_initialize_for_gvlogin(data)
      user.email = data.mail
      user
    end

    def success_login
      flash[:success] = I18n.t("devise.sessions.signed_in")

      sign_in_and_redirect @user, event: :authentication
    end

    def error_login
      @user.send("#{GVA_ROLES[role]}").delete if @user.send("#{GVA_ROLES[role]}?")
      flash[:error] = I18n.t("devise.failure.no_backend_roles")
      delete_cookies

      redirect_to new_user_session_path
    end

    def error_save_user
      errors = @user.errors
      flash[:error] = errors.messages.map { |field, error| "#{field}: #{error.join(", ")} ('#{errors.details[field][0][:value]}')" }.join(", ")
      delete_cookies

      redirect_to new_user_session_path
    end

    def error_user_data
      flash[:error] = I18n.t("devise.failure.no_codeper_email")
      delete_cookies

      redirect_to new_user_session_path
    end

    def save_user(data)
      if @user.save
        role = data.roles.present? ? data.roles&.dig(:role, :codigo) : ""
        if GVA_ROLES.include?(role)
          @user.send("create_#{GVA_ROLES[role]}") unless @user.send("#{GVA_ROLES[role]}?")
          # Only sign in if admin right now
          # Move sign_in outside of if when other roles added
          success_login
        else
          error_login
        end
      else
        error_save_user
      end
    end
 end
