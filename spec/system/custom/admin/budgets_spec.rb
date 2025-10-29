require "rails_helper"

describe "Admin budgets", :admin do
  context "Edit" do
    let(:budget) { create(:budget) }

    scenario "Show results and stats settings" do
      visit edit_admin_budget_path(budget)

      within_fieldset "Display results and statistics" do
        expect(page).to have_field "Show results"
        expect(page).to have_field "Show stats"
        expect(page).to have_field "Show advanced stats"
      end
    end

    scenario "Show CTA link in public site if added" do
      visit edit_admin_budget_path(budget)

      expect(page).to have_content("Main call to action (optional)")

      fill_in "Text on the link", with: "Participate now"
      fill_in "The link takes you to (add a link)", with: "https://consuldemocracy.org"
      click_button "Update Budget"

      expect(page).to have_content "Participatory budget updated successfully"

      visit budgets_path
      expect(page).to have_link("Participate now", href: "https://consuldemocracy.org")
    end

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

      select "Eng", from: :select_language
      fill_in "Name", with: "New English Name"
      click_button "Update Budget"

      expect(page).to have_content "Participatory budget updated successfully"

      visit budget_path(id: "new-english-name")

      expect(page).to have_content "New English Name"
    end
  end
end
