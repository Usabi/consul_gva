require "rails_helper"

describe "Admin budget headings", :admin do
  let(:budget) { create(:budget, :drafting) }
  let!(:group) { create(:budget_group, budget: budget) }

  context "Edit" do
    scenario "Changing name for current locale will update the slug if budget is in draft phase" do
      heading = create(:budget_heading, group: group, name: "Old English Name")

      visit edit_admin_budget_group_heading_path(budget, group, heading)

      select "Cast", from: :add_language
      fill_in "Heading name", with: "Spanish name"
      click_button "Save heading"

      expect(page).to have_content "Heading updated successfully"

      visit budget_investments_path(budget, heading_id: "old-english-name")

      expect(page).to have_content "Old English Name"

      visit edit_admin_budget_group_heading_path(budget, group, heading)

      select "English", from: :select_language
      fill_in "Heading name", with: "New English Name"
      click_button "Save heading"

      expect(page).to have_content "Heading updated successfully"

      visit budget_investments_path(budget, heading_id: "new-english-name")

      expect(page).to have_content "New English Name"
    end
  end
end
