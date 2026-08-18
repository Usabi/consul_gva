load Rails.root.join("app", "controllers", "users", "sessions_controller.rb")

class Users::SessionsController
  include CaptchaProtected

  private

    def captcha_resource_params
      sign_in_params
    end
end
