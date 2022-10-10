namespace :gvlogin_user_desa do
  desc "Resets organization user"
  task reset_organizations: :environment do
    ApplicationLogger.new.info "Find user"
    user = User.find(27)
    ApplicationLogger.new.info user.email
    user.organization.destroy
    user.organization = nil
    ApplicationLogger.new.info "Organization user removed"
    if user.save!
      ApplicationLogger.new.info "User saved"
    else
      ApplicationLogger.new.info "Error saved"
      ApplicationLogger.new.info user.errors.full_messages
    end
  end
end
