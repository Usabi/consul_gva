# config/initializers/recaptcha.rb
Recaptcha.configure do |config|
  config.site_key = Rails.application.secrets.site_key
  config.secret_key = Rails.application.secrets.secret_key

  # Uncomment the following line if you are using a proxy server:
  # config.proxy = 'http://myproxy.com.au:8080'

  # Uncomment the following lines if you are using the Enterprise API:
  # config.enterprise = Rails.application.secrets.recaptcha_enterprise
  # config.enterprise_api_key = Rails.application.secrets.recaptcha_enterprise_api_key
  # config.enterprise_project_id = Rails.application.secrets.recaptcha_enterprise_project_id
end
