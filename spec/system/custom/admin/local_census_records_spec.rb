require "rails_helper"

describe "Admin local census records", :admin do
  context "Create" do
    scenario "Should show successful notice after create valid record with date selectors" do
      visit new_admin_local_census_record_path

      select "DNI", from: :local_census_record_document_type
      fill_in :local_census_record_document_number, with: "#DOCUMENT"
      select "1982", from: "local_census_record_date_of_birth_1i"
      select "July", from: "local_census_record_date_of_birth_2i"
      select "7", from: "local_census_record_date_of_birth_3i"
      fill_in :local_census_record_postal_code, with: "07003"
      click_button "Save"

      expect(page).to have_content "New local census record created successfully!"
      expect(page).to have_content "DNI"
      expect(page).to have_content "#DOCUMENT"
      expect(page).to have_content "1982-07-07"
      expect(page).to have_content "07003"
    end
  end
end
