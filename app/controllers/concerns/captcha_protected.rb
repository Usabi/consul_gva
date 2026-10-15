module CaptchaProtected
  extend ActiveSupport::Concern

  included do
    before_action :generate_ptt_captcha, only: [:new]
    prepend_before_action :check_captcha, only: [:create]
  end

  private

    def ptt_enabled?
      PttCaptcha.configuration.app_id.present?
    end

    def google_recaptcha_enabled?
      Rails.application.secrets.site_key.present? && Rails.application.secrets.secret_key.present?
    end

    # Si PTT está configurado pero no se puede crear el captcha, el formulario
    # muestra Google reCAPTCHA (si hay claves). Se deja constancia en sesión
    # para validar con el mismo captcha que se mostró; sin esa marca se exige
    # PTT, de modo que no se puede forzar el camino de Google desde fuera.
    def generate_ptt_captcha
      return unless ptt_enabled?

      captcha_id = PttCaptchaApi.create_captcha

      if captcha_id.present?
        session[:ptt_captcha_id] = captcha_id
        session.delete(:captcha_fallback)
      else
        session.delete(:ptt_captcha_id)
        session[:captcha_fallback] = "google" if google_recaptcha_enabled?
      end
    end

    def check_captcha
      if ptt_enabled? && !google_fallback_active?
        check_ptt_captcha
      elsif google_recaptcha_enabled?
        check_google_recaptcha
      end
    end

    def google_fallback_active?
      session[:captcha_fallback] == "google" && google_recaptcha_enabled?
    end

    def check_ptt_captcha
      id_captcha    = session[:ptt_captcha_id]
      valor_captcha = params[:ptt_valor_captcha]

      return if id_captcha.present? && PttCaptchaApi.validate_captcha(id_captcha, valor_captcha)

      session.delete(:ptt_captcha_id)
      generate_ptt_captcha
      render_captcha_error
    end

    def check_google_recaptcha
      return if verify_recaptcha

      render_captcha_error
    end

    def render_captcha_error
      self.resource = resource_class.new captcha_resource_params

      respond_with_navigational(resource) do
        flash.delete(:notice)
        flash[:alert] = t("devise.recaptcha.errors.verification_failed")
        render :new
      end
    end
end
