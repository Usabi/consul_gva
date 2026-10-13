load Rails.root.join("app", "components", "admin", "settings", "configuration_tab_component.rb")

class Admin::Settings::ConfigurationTabComponent
  alias_method :consul_settings, :settings

  def settings
    consul_settings + %w[admin_guide_url legislator_guide_url help_contact_email help_contact_website]
  end
end
