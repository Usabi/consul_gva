require "rails_helper"

describe "Budgets creation wizard", :admin do
  scenario "Creation of a single-heading budget by steps", :js do
    visit admin_budgets_path
    click_button "Create new budget"
    click_link "Create single heading budget"

    fill_in "Name", with: "Single heading budget"
    click_button "Continue to groups"

    expect(page).to have_content "New participatory budget created successfully!"
    expect(page).to have_field "Group name", with: "Single heading budget"

    click_button "Continue to headings"

    expect(page).to have_content "Group created successfully"

    fill_in "Heading name", with: "One and only heading"
    fill_in "Money amount", with: "1000000"
    fill_in "Population (optional)", with: "10000"
    click_button "Continue to phases"

    expect(page).to have_css ".budget-phases-table"

    click_link "Finish"

    within "section", text: "Heading groups" do
      expect(page).to have_content "Single heading budget"

      within "tbody" do
        expect(page).to have_content "One and only heading"
      end
    end
  end
end
