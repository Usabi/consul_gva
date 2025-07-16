require "rails_helper"
require "sessions_helper"

describe "Budget Investments" do
  let(:budget) { create(:budget, name: "Big Budget") }
  let(:group) { create(:budget_group, name: "Health", budget: budget) }
  let!(:heading) { create(:budget_heading, name: "More hospitals", price: 666666, group: group) }

  context("Filters") do
    context "Results Phase" do
      before { budget.update(phase: "finished", results_enabled: true) }

      scenario "unselected" do
        investment1 = create(:budget_investment, :unselected, heading: heading)
        investment2 = create(:budget_investment, :selected, heading: heading)

        visit budget_results_path(budget)
        click_link "See the list of expenditure projects not selected for the evaluation phase."

        within("#budget-investments") do
          expect(page).to have_css(".budget-investment", count: 1)
          expect(page).to have_content(investment1.title)
          expect(page).not_to have_content(investment2.title)
        end
      end
    end
  end
end
