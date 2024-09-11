require "rails_helper"

describe "Admin Budgets", :admin do
  context "Index" do

    scenario "Create poll in current locale if the budget does not have a poll associated" do
      budget = create(:budget,
                      name_en: "Budget for climate change",
                      name_es: "Presupuesto por el cambio climático")

      visit admin_budget_path(budget)
      select_language("Cast")

      accept_confirm { click_button "Crear urnas" }

      expect(page).to have_current_path(/admin\/polls\/\d+/)
      expect(page).to have_content "Presupuesto por el cambio climático"
    end
  end
end
