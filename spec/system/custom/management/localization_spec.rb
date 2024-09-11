require "rails_helper"

describe "Localization" do
  scenario "Changing the locale" do
    login_as_manager
    select_language("Cast")

    within(".radio-toolbar") do
      expect(find("#local-Cast", visible: false)).to be_checked
    end
    expect(page).to have_content "Gestión"
  end
end
