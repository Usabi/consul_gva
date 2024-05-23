require "rails_helper"

describe "Admin budgets", :admin do

  context "Edit" do
    let(:budget) { create(:budget) }

    scenario "Changing name for current locale will update the slug if budget is in draft phase" do
      budget.update!(published: false, name: "Old English Name")

      visit edit_admin_budget_path(budget)

      select "Cast", from: :add_language
      fill_in "Name", with: "Spanish name"
      click_button "Update Budget"

      expect(page).to have_content "Participatory budget updated successfully"

      visit budget_path(id: "old-english-name")

      expect(page).to have_content "Old English Name"

      visit edit_admin_budget_path(budget)

      select "English", from: :select_language
      fill_in "Name", with: "New English Name"
      click_button "Update Budget"

      expect(page).to have_content "Participatory budget updated successfully"

      visit budget_path(id: "new-english-name")

      expect(page).to have_content "New English Name"
    end
  end
end
