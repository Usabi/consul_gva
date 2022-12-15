require_dependency Rails.root.join("app", "controllers", "users", "registrations_controller").to_s

class Users::RegistrationsController
  if Rails.application.secrets.site_key.present?
    prepend_before_action :check_captcha, only: [:create]
  end

  private

    def check_captcha
      return if verify_recaptcha

      self.resource = resource_class.new sign_up_params

      respond_with_navigational(resource) do
        flash.delete(:recaptcha_error)
        flash.delete(:notice)
        flash[:alert] = t("devise.recaptcha.errors.verification_failed")
        render :new
      end
    end
end
