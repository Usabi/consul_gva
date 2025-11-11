require "rails_helper"

describe "Admin banners magement", :admin do
  scenario "Publish a banner with a translation different than the current locale" do
    visit new_admin_banner_path

    expect_to_have_language_selected "Eng"

    click_link "Remove language"
    select "Français", from: "Add language"

    fill_in "Title", with: "En Français"
    fill_in "Description", with: "Link en Français"
    fill_in "Link", with: "https://www.url.com"
    fill_in "Post started at", with: Date.current - 1.week
    fill_in "Post ended at", with: Date.current + 1.week

    click_button "Save changes"
    click_link "Edit"

    expect_to_have_language_selected "Français"
    expect(page).to have_field "Title", with: "En Français"
  end
end
