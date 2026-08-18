load Rails.root.join("app", "controllers", "users", "registrations_controller.rb")

class Users::RegistrationsController
  include CaptchaProtected

  private

    def captcha_resource_params
      sign_up_params
    end
end
