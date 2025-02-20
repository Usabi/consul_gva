load Rails.root.join("app", "controllers", "budgets_controller.rb")

class BudgetsController
  has_filters %w[not_unfeasible feasible unfeasible unselected selected winners not_selected], only: :show
end

