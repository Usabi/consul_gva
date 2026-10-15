namespace :ptt_captcha do
  desc "Verify PTT captcha configuration (logs only presence of keys, never their values)"
  task verify: :environment do
    logger = ApplicationLogger.new
    config = PttCaptcha.configuration

    logger.info "Verify keys PTT captcha"
    logger.info "Rails env: #{Rails.env}"
    logger.info "PTT endpoint: #{PttCaptchaApi.base_url}"
    logger.info "PTT app_id present: #{config.app_id.present?}"
    logger.info "PTT x_api_key present: #{config.x_api_key.present?}"
    logger.info "PTT aplicacion present: #{config.aplicacion.present?}"

    site_key = Rails.application.secrets.site_key.present?
    secret_key = Rails.application.secrets.secret_key.present?
    google = site_key && secret_key

    logger.info "Google site_key present: #{site_key}"
    logger.info "Google secret_key present: #{secret_key}"
    logger.info "Google reCAPTCHA usable: #{google}"
    keys_present = config.app_id.present? && config.x_api_key.present? && config.aplicacion.present?

    if keys_present
      captcha_id = PttCaptchaApi.create_captcha

      if captcha_id.present?
        logger.info "PTT create_captcha: OK"
        logger.info "Captcha in use: PTT"
      else
        logger.warn "PTT create_captcha: FAILED (check PttCaptchaApi errors in log/#{Rails.env}.log)"
        logger.warn "PTT last error: #{PttCaptchaApi.last_error}" if PttCaptchaApi.last_error.present?
        logger.warn "Captcha in use: #{google ? "Google reCAPTCHA (PTT unavailable)" : "none"}"
      end
    else
      logger.warn "PTT create_captcha: SKIPPED (missing PTT keys)"
      logger.info "Captcha in use: #{google ? "Google reCAPTCHA" : "none"}"
    end
  end
end
