# config/initializers/ptt_captcha.rb
require Rails.root.join("app", "lib", "custom", "ptt_captcha")

PttCaptcha.configure do |config|
  config.app_id = Rails.application.secrets.ptt_app_id
  config.x_api_key = Rails.application.secrets.ptt_x_api_key
  config.aplicacion = Rails.application.secrets.ptt_aplicacion
end
