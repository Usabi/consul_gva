require "rails_helper"

describe "Admin budget groups", :admin do
  let(:budget) { create(:budget, :drafting) }

  context "Edit" do
    scenario "Changing name for current locale will update the slug if budget is in draft phase" do
      group = create(:budget_group, budget: budget, name: "Old English Name")

      visit edit_admin_budget_group_path(budget, group)

      select "Cast", from: :add_language
      fill_in "Group name", with: "Spanish name"
      click_button "Save group"

      expect(page).to have_content "Group updated successfully"

      visit budget_group_path(budget, id: "old-english-name")

      expect(page).to have_content "Select a heading"

      visit edit_admin_budget_group_path(budget, group)

      select "English", from: :select_language
      fill_in "Group name", with: "New English Name"
      click_button "Save group"

      expect(page).to have_content "Group updated successfully"

      visit budget_group_path(budget, id: "new-english-name")

      expect(page).to have_content "Select a heading"
    end
  end
end
