require "rails_helper"

describe "Admin proposals", :admin do

  context "Index" do
    scenario "Search" do
      create(:proposal, title: "Make Pluto a planet again")
      create(:proposal, title: "Build a monument to honour CONSUL developers")

      visit admin_root_path
      within("#side_menu") { click_link "Proposals" }

      expect(page).to have_content "Make Pluto a planet again"
      expect(page).to have_content "Build a monument"

      fill_in "title_or_id", with: "Pluto"
      click_button "Filter"

      expect(page).to have_content "Make Pluto a planet again"
      expect(page).not_to have_content "Build a monument"
    end
  end
end
