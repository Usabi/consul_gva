class Users::GvLoginController < ApplicationController
  skip_authorization_check :login_or_redirect_to_sso

  def login_or_redirect_to_sso
    remote_ip = request.x_forwarded_for
    cookie = cookies["gvlogin.login.GVLOGIN_COOKIE"]
    gvlogin_api = GVLoginApi.new(request.host)
    if cookie
      check_context = gvlogin_api.context(remote_ip, cookie)
      if check_context.valid?
        sign_in_gvlogin(check_context.data)
      else
        flash[:error] = check_context.errors
        redirect_to gvlogin_api.web_gv_login
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
      auth = OpenStruct.new(uid: data.dni, provider: :gvlogin)
      identity = Identity.first_or_create_from_oauth(auth)
      @user = identity.user || User.first_or_initialize_for_gvlogin(auth, data)

      if save_user
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