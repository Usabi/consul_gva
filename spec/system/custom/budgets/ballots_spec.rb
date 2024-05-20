require "rails_helper"
require "sessions_helper"

describe "Ballots" do
  let(:user)        { create(:user, :level_two) }
  let!(:budget)     { create(:budget, :balloting) }
  let!(:states)     { create(:budget_group, budget: budget, name: "States") }
  let!(:california) { create(:budget_heading, group: states, name: "California", price: 1000) }
  let!(:new_york)   { create(:budget_heading, group: states, name: "New York", price: 1000000) }

  context "Voting" do
    before { login_as(user) }

    let!(:city) { create(:budget_group, budget: budget, name: "City") }
    let!(:districts) { create(:budget_group, budget: budget, name: "Districts") }

    context "Group and Heading Navigation" do
      before do
        allow(I18n).to receive(:available_locales).and_return(%i[es val])
        allow(I18n).to receive(:locale).and_return(:val)
      end
      scenario "Headings" do
        create(:budget_heading, group: city,      name: "Investments Type1")
        create(:budget_heading, group: city,      name: "Investments Type2")
        create(:budget_heading, group: districts, name: "District 1")
        create(:budget_heading, group: districts, name: "District 2")

        visit budget_path(budget)

        within("#groups_and_headings") do
          expect(page).to have_link "Investments Type1"
          expect(page).to have_link "Investments Type2"
          expect(page).to have_link "District 1"
          expect(page).to have_link "District 2"
        end
      end

      scenario "Investments" do
        create(:budget_heading, group: city, name: "Under the city")

        create(:budget_heading, group: city, name: "Above the city") do |heading|
          create(:budget_investment, :selected, heading: heading, title: "Solar panels")
          create(:budget_investment, :selected, heading: heading, title: "Observatory")
        end

        create(:budget_heading, group: districts, name: "District 1") do |heading|
          create(:budget_investment, :selected, heading: heading, title: "New park")
          create(:budget_investment, :selected, heading: heading, title: "Zero-emission zone")
        end

        create(:budget_heading, group: districts, name: "District 2") do |heading|
          create(:budget_investment, :selected, heading: heading, title: "Climbing wall")
        end

        visit budget_path(budget)
        click_link "Above the city"

        expect(page).to have_css(".budget-investment", count: 2)
        expect(page).to have_content "Solar panels"
        expect(page).to have_content "Observatory"

        visit budget_path(budget)
        click_link "District 1"

        expect(page).to have_css(".budget-investment", count: 2)
        expect(page).to have_content "New park"
        expect(page).to have_content "Zero-emission zone"

        visit budget_path(budget)
        click_link "District 2"

        expect(page).to have_css(".budget-investment", count: 1)
        expect(page).to have_content "Climbing wall"
      end
    end
  end
end
