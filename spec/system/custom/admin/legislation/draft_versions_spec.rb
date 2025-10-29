require "rails_helper"

describe "Admin legislation draft versions", :admin do
  context "Index" do
    scenario "Displaying legislation process draft versions" do
      process = create(:legislation_process, title: "An example legislation process")
      draft_version = create(:legislation_draft_version, process: process, title: "Version 1")

      visit admin_legislation_processes_path(filter: "all")

      within("tr", text: "An example legislation process") { click_link "Edit" }
      click_link "Draft"
      click_link "Version 1"

      expect(page).to have_content(draft_version.changelog)
    end
  end

  context "Create" do
    scenario "Valid legislation draft version" do
      create(:legislation_process, title: "An example legislation process")

      visit admin_root_path

      within("#side_menu") do
        click_button "Legislation"
        within("#legislation_menu") do
          click_link "Legislation"
        end
      end

      within("tr", text: "An example legislation process") { click_link "Edit" }
      click_link "Draft"

      click_link "Create version"

      fill_in "Version title", with: "Version 3"
      fill_in "Changes", with: "Version 3 changes"
      fill_in_markdown_editor "Text", with: "Version 3 body"

      within("form .end") do
        click_button "Create version"
      end

      expect(page).to have_content "An example legislation process"
      expect(page).to have_content "Version 3"
    end
  end

  context "Update" do
    scenario "Valid legislation draft version" do
      process = create(:legislation_process, title: "An example legislation process")
      create(:legislation_draft_version, title: "Version 1", process: process)

      visit admin_root_path

      within("#side_menu") do
        click_button "Legislation"
        within("#legislation_menu") do
          click_link "Legislation"
        end
      end

      within("tr", text: "An example legislation process") { click_link "Edit" }
      click_link "Draft"

      click_link "Version 1"

      fill_in "Version title", with: "Version 2"
      fill_in "Changes", with: "Version 2 changes"
      fill_in_markdown_editor "Text", with: "Version 2 body"

      within("form .end") do
        click_button "Save changes"
      end

      expect(page).to have_content "An example legislation process"
      expect(page).to have_content "Version 2"
      expect(page).to have_content "Version 2 changes"
    end
  end
end
