require "rails_helper"

describe "Admin custom information texts", :admin do

  context "Globalization" do

    scenario "Remove a translation" do
      featured = create(:i18n_content, key: "debates.index.featured_debates",
                                       value_en: "Custom featured",
                                       value_es: "Destacar personalizado")

      page_title = create(:i18n_content, key: "debates.new.start_new",
                                          value_en: "Start a new debate",
                                          value_es: "Empezar un debate")

      visit admin_site_customization_information_texts_path(tab: "debates")

      select "Cast", from: :select_language
      click_link "Remove language"
      click_button "Save"

      expect(page).not_to have_link "Cast"

      visit admin_site_customization_information_texts_path(tab: "debates")
      select "English", from: :select_language

      expect(page).to have_content "Start a new debate"
      expect(page).to have_content "Custom featured"

      featured.reload
      page_title.reload

      expect(page_title.value_es).to be nil
      expect(featured.value_es).to be nil
      expect(page_title.value_en).to eq "Start a new debate"
      expect(featured.value_en).to eq "Custom featured"
    end
  end
end
