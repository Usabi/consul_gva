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
      @user = User.first_or_initialize_for_gvlogin(data)
      if @user.save
        role = data.roles.present? ? data.roles&.dig(:role, :codigo) : ""
        if role == "PARTICIPEM_ADMIN"
          @user.send("create_#{GVA_ROLES[role]}") unless @user.send("#{GVA_ROLES[role]}?")
          # Only sign in if admin right now
          # Move sign_in outside of if when other roles added
          flash[:success] = I18n.t("devise.sessions.signed_in")
          sign_in_and_redirect @user, event: :authentication
        else
          @user.administrator.delete if @user.administrator?
          flash[:error] = I18n.t("devise.failure.no_backend_roles")
          cookies.delete("gvlogin.login.GVLOGIN_COOKIE")
          redirect_to new_user_session_path
        end
      else
        errors = @user.errors
        flash[:error] = errors.messages.map {|field, error| "#{field}: #{error.join(", ")} ('#{errors.details[field][0][:value]}')" }.join(", ")
        cookies.delete("gvlogin.login.GVLOGIN_COOKIE")
        redirect_to new_user_session_path
      end
    end
 end
