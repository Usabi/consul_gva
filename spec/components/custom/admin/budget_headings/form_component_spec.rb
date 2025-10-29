require "rails_helper"

describe Admin::BudgetHeadings::FormComponent do
  describe "geozone field" do
    let(:heading) { create(:budget_heading) }
    let(:component) { Admin::BudgetHeadings::FormComponent.new(heading, path: "/", action: nil) }

    it "is not shown even when the map feature is enabled" do
      Setting["feature.map"] = true
      render_inline component

      expect(page).not_to have_select "Scope of operation"
    end

    it "is not shown when the map feature is disabled" do
      Setting["feature.map"] = false
      render_inline component

      expect(page).not_to have_select "Scope of operation"
    end
  end
end
