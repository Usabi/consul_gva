require "rails_helper"

describe "Custom SDG Relations" do
  before do
    login_as(create(:administrator).user)
    Setting["feature.sdg"] = true
    Setting["sdg.process.budgets"] = true
    Setting["sdg.process.debates"] = true
    Setting["sdg.process.legislation"] = true
    Setting["sdg.process.polls"] = true
    Setting["sdg.process.proposals"] = true
  end

  describe "Index" do
    describe "search" do
      scenario "goal filter" do
        create(:budget_investment, title: "School", sdg_goals: [SDG::Goal[4]])
        create(:budget_investment, title: "Hospital", sdg_goals: [SDG::Goal[3]])

        goal_4_targets = [
          "4.1. Free Primary and Secondary Education",
          "4.2. Equal Access to Quality Pre-Primary Education",
          "4.3. Equal Access to Affordable Technical, Vocational and Higher Education",
          "4.4. Increase the Number of People with Relevant Skills for Financial Success",
          "4.5. Eliminate All Discrimination in Education",
          "4.6. Universal Literacy and Numeracy",
          "4.7. Education for Sustainable Development and Global Citizenship",
          "4.A. Build and Upgrade Inclusive and Safe Schools",
          "4.B. Expand Higher Education Scholarships for Developing Countries",
          "4.C. Increase the supply of qualified teachers In Developing Countries"
        ]

        visit sdg_management_budget_investments_path
        select "4. Quality Education", from: "goal_code"
        click_button "Search"

        expect(page).to have_content "School"
        expect(page).not_to have_content "Hospital"
        expect(page).to have_css "li.is-active h2", exact_text: "Pending"

        expect(page).to have_select "By goal",
                                    selected: "All goals",
                                    enabled_options: ["All goals"] + goal_4_targets
      end

      scenario "dynamic target options depending on the selected goal" do
        goal_1_targets = [
          "1.1. Eradicate Extreme Poverty",
          "1.2. Reduce Poverty by at Least 50%",
          "1.3. Implement Social Protection Systems",
          "1.4. Equal Rights to Ownership, Basic Services, Technology and Economic Resources",
          "1.5. Build Resilience to Environmental, Economic and Social Disasters",
          "1.A. Mobilize Resources to Implement Policies to End Poverty",
          "1.B. Create pro-poor and gender-sensitive policy frameworks"
        ]

        goal_13_targets = [
          "13.1. Strengthen resilience and Adaptive Capacity to Climate Related Disasters",
          "13.2. Integrate Climate Change Measures into Policies and Planning",
          "13.3. Build Knowledge and Capacity to Meet Climate Change",
          "13.A. Implement the UN Framework Convention on Climate Change",
          "13.B. Promote Mechanisms to Raise Capacity for Planning and Management"
        ]

        visit sdg_management_polls_path

        select "1. No Poverty", from: "By objective"

        expect(page).to have_select "By goal",
                                    selected: "All goals",
                                    enabled_options: ["All goals"] + goal_1_targets

        select "1.1. Eradicate Extreme Poverty", from: "By goal"
        select "13. Climate Action", from: "By objective"

        expect(page).to have_select "By goal",
                                    selected: "All goals",
                                    enabled_options: ["All goals"] + goal_13_targets

        select "13.3. Build Knowledge and Capacity to Meet Climate Change", from: "By goal"
        select "All objectives", from: "By objective"

        expect(page).to have_select "By goal",
                                    selected: "13.3. Build Knowledge and Capacity to Meet Climate Change",
                                    disabled_options: []
      end
    end
  end
end
