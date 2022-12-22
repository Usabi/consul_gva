require_dependency Rails.root.join("app", "controllers", "users", "sessions_controller").to_s

class Users::SessionsController
  if Rails.application.secrets.site_key.present?
    prepend_before_action :check_captcha, only: [:create]
  end

  private

    def check_captcha
      return if verify_recaptcha

      self.resource = resource_class.new sign_in_params

      respond_with_navigational(resource) do
        flash.delete(:recaptcha_error)
        flash.delete(:notice)
        flash[:alert] = t("devise.recaptcha.errors.verification_failed")
        render :new
      end
    end
end
