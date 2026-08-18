load Rails.root.join("app", "controllers", "users", "sessions_controller.rb")

class Users::SessionsController
  before_action :generate_ptt_captcha, only: [:new]
  prepend_before_action :check_captcha, only: [:create]

  private

    def ptt_enabled?
      Rails.application.secrets.ptt_app_id.present?
    end

    def generate_ptt_captcha
      return unless ptt_enabled?
      @ptt_captcha_id = PttCaptchaApi.crear
      session[:ptt_captcha_id] = @ptt_captcha_id
    end

    def check_captcha
      return unless ptt_enabled?

      id_captcha    = session[:ptt_captcha_id]
      valor_captcha = params[:ptt_valor_captcha]

      return if id_captcha.present? && PttCaptchaApi.validar(id_captcha, valor_captcha)

      session.delete(:ptt_captcha_id)
      generate_ptt_captcha

      self.resource = resource_class.new sign_in_params

      respond_with_navigational(resource) do
        flash.delete(:notice)
        flash[:alert] = t("devise.recaptcha.errors.verification_failed")
        render :new
      end
    end
end
