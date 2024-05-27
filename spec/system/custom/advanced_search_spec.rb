require "rails_helper"

describe "Advanced search" do
  let(:budget)  { create(:budget, name: "Big Budget") }
  let(:heading) { create(:budget_heading, budget: budget, name: "More hospitals") }

  describe "SDG" do
    before do
      Setting["feature.sdg"] = true
      Setting["sdg.process.debates"] = true
      Setting["sdg.process.proposals"] = true
      Setting["sdg.process.budgets"] = true
    end

    scenario "Search by goal" do
      create(:budget_investment, title: "Purifier", heading: heading, sdg_goals: [SDG::Goal[6]])
      create(:budget_investment, title: "Hospital", heading: heading, sdg_goals: [SDG::Goal[3]])

      goal_6_targets = [
        "6.1. Safe and Affordable Drinking Water",
        "6.2. End Open Defecation and Provide Access to Sanitation and Hygiene",
        "6.3. Improve Water Quality, Wastewater Treatment and Safe Reuse",
        "6.4. Increase Water-Use Efficiency and Ensure Freshwater Supplies",
        "6.5. Implement Integrated Water Resources Management",
        "6.6. Protect and Restore Water-Related Ecosystems",
        "6.A. Expand Water and Sanitation Support to Developing Countries",
        "6.B. Support Local Engagement in Water and Sanitation Management"
      ]

      visit budget_investments_path(budget)
      click_button "Advanced search"
      select "6. Clean Water and Sanitation", from: "By SDG"
      click_button "Filter"

      expect(page).to have_content("There are 2 investments")

      within("#budget-investments") do
        expect(page).to have_content "Purifier"
        expect(page).to have_content "Hospital"
      end

      expect(page).to have_select "By target",
                                  selected: "Select a target",
                                  enabled_options: ["Select a target"] + goal_6_targets
    end

    scenario "Search by target" do
      create(:debate, title: "Unrelated")
      create(:debate, title: "High school", sdg_targets: [SDG::Target["4.1"]])
      create(:debate, title: "Preschool", sdg_targets: [SDG::Target["4.2"]])

      visit debates_path
      click_button "Advanced search"
      select "4.2. Equal Access to Quality Pre-Primary Education", from: "By target"
      click_button "Filter"

      expect(page).to have_content("There are 3 debates")

      within("#debates") do
        expect(page).to have_content("Preschool")
        expect(page).to have_content("High school")
        expect(page).to have_content("Unrelated")
      end
    end
  end
end
