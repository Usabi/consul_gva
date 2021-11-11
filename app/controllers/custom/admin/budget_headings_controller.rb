require_dependency Rails.root.join("app", "controllers", "admin", "budget_headings_controller").to_s

class Admin::BudgetHeadingsController
  private

    def budget_heading_params
      valid_attributes = [:price, :population, :allow_custom_content, :latitude, :longitude, :max_ballot_lines, :min_supports]
      params.require(:budget_heading).permit(*valid_attributes, translation_params(Budget::Heading))
    end
end
