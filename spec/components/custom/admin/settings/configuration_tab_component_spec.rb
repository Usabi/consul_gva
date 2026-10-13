require "rails_helper"

describe Admin::Settings::ConfigurationTabComponent do
  it "includes the guide URL settings" do
    component = Admin::Settings::ConfigurationTabComponent.new

    expect(component.settings).to include "admin_guide_url", "legislator_guide_url",
                                          "help_contact_email", "help_contact_website"
  end
end
