require "rails_helper"

describe "Localization" do
  scenario "Changing the locale" do
    visit "/"
    select_language("Cast")

    within(".radio-toolbar") do
      expect(find("#local-Cast", visible: false)).to be_checked
    end
  end

  scenario "Keeps query parameters while using protected redirects" do
    visit "/debates?order=created_at&host=evil.dev"

    select_language("Cast")

    expect(current_host).to eq "http://127.0.0.1"
    expect(page).to have_current_path "/debates?locale=es&order=created_at"
  end

  scenario "uses default locale when session locale has disappeared" do
    default_locales = I18n.available_locales

    visit root_path(locale: :es)

    expect(page).to have_content "Iniciar sesión"

    begin
      I18n.available_locales = default_locales - [:es]

      visit root_path

      expect(page).to have_content "Sign in"
    ensure
      I18n.available_locales = default_locales
    end
  end
end
