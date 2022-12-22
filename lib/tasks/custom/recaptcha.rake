namespace :recaptcha do
  desc "Verify recaptcha"
  task verify_recaptcha: :environment do
    ApplicationLogger.new.info "Verify keys recapcha"
    ApplicationLogger.new.info "Exists site keys"
    ApplicationLogger.new.info Rails.application.secrets.site_key.present?
  end
end
