require "rails_helper"

describe "Admin footer information texts", :admin do
  scenario "Footer tab lists only the footer texts" do
    visit admin_site_customization_information_texts_path

    within("#information-texts-tabs") { click_link "Footer" }

    expect(page).to have_content "layouts.footer.privacy"
    expect(page).to have_content "application.slogan_text.footer"
    expect(page).not_to have_content "debates.index.section_footer.title"
  end

  scenario "Edited footer text is shown in the public footer" do
    visit admin_site_customization_information_texts_path(tab: "footer")

    fill_in "contents_content_layouts.footer.privacyvalues_value_en", with: "Custom privacy"
    click_button "Save"

    visit root_path

    within("footer") { expect(page).to have_link "Custom privacy" }
  end
end
