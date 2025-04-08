class Admin::Dashboard::GuidesComponent < ApplicationComponent
  private

    def email_link
      mail_to "info@consulfoundation.org"
    end

    def website_link
      link_to "https://consuldemocracy.org", "https://consuldemocracy.org"
    end
end
