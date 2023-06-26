require_dependency Rails.root.join("app", "controllers", "admin", "budget_investments_controller").to_s

class Admin::BudgetInvestmentsController
  def allowed_params
    attributes = [:external_url, :heading_id, :administrator_id, :tag_list,
                  :valuation_tag_list, :incompatible, :visible_to_valuators, :selected, :not_selected, :supported,
                  :milestone_tag_list, valuator_ids: [], valuator_group_ids: []]
    [*attributes, translation_params(Budget::Investment)]
  end
end
