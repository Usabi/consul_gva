class Users::GvLoginController < ApplicationController
  skip_authorization_check :login_or_redirect_to_sso

  GVA_ROLES = {
    "PARTICIPEM_ADMIN" => :administrator
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
      end
    else
      redirect_to gvlogin_api.web_gv_login
    end
  end

  def after_sign_in_path_for(resource)
    if resource.registering_with_oauth
      finish_signup_path
    else
      root_path
    end
  end

  private

    def sign_in_gvlogin(data)
      uid = data.info_ampliada["codper"].presence || data.dni
      auth = OpenStruct.new(uid: uid, provider: :gvlogin)
      identity = Identity.first_or_create_from_oauth(auth)
      @user = identity.user || User.first_or_initialize_for_gvlogin(data)
      if save_user
        role = data.roles.present? ? data.roles&.dig(:role, :codigo) : ""
        if role == "PARTICIPEM_ADMIN"
          @user.send("create_#{GVA_ROLES[role]}") unless @user.send("#{GVA_ROLES[role]}?")
        else
          @user.administrator.delete if @user.administrator?
        end
        identity.update!(user: @user)
        sign_in_and_redirect @user, event: :authentication
        flash[:success] = I18n.t("devise.sessions.signed_in")
      else
        redirect_to gvlogin_api.web_gv_login
      end
    end

    def save_user
      @user.save || @user.save_requiring_finish_signup
    end
 end
