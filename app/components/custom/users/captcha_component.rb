class Users::CaptchaComponent < ApplicationComponent
  def render?
    ptt_enabled? || google_enabled?
  end

  def ptt_enabled?
    ptt_captcha_id.present?
  end

  def google_enabled?
    Rails.application.secrets.site_key.present? && Rails.application.secrets.secret_key.present?
  end

  private

    def ptt_captcha_id
      request.session[:ptt_captcha_id]
    end

    def ptt_idioma
      I18n.locale.to_s == "val" ? "va" : I18n.locale.to_s
    end
end
