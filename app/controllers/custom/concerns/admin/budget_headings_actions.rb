
require_dependency Rails.root.join("app", "controllers", "concerns", "admin", "budget_headings_actions").to_s

module Admin::BudgetHeadingsActions
  private

    def allowed_params
      valid_attributes = [:price, :population, :allow_custom_content, :latitude, :longitude, :max_ballot_lines, :min_supports]

      [*valid_attributes, translation_params(Budget::Heading)]
    end
end
