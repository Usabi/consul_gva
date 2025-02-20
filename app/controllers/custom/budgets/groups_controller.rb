load Rails.root.join("app", "controllers", "budgets", "groups_controller.rb")

class Budgets::GroupsController
  has_filters %w[not_unfeasible feasible unfeasible unselected selected winners not_selected], only: :show
end


