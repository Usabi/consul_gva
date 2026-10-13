class Admin::Dashboard::GuidesComponent < ApplicationComponent
  private

    def admin_guide_url
      Setting["admin_guide_url"].presence
    end

    def legislator_guide_url
      Setting["legislator_guide_url"].presence
    end

    def contact_email
      Setting["help_contact_email"].presence
    end

    def contact_website
      Setting["help_contact_website"].presence
    end

    def contact_info?
      contact_email || contact_website
    end

    def email_link
      mail_to contact_email
    end

    def website_link
      link_to contact_website, contact_website
    end
end
