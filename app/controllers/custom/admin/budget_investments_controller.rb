require_dependency Rails.root.join("app", "controllers", "admin", "budget_investments_controller").to_s

class Admin::BudgetInvestmentsController

  before_action :load_investment, only: [:show, :edit, :update, :toggle_selection, :toggle_winner]

  def toggle_winner
    authorize! :toggle_winner, @investment
    @investment.toggle :winner
    @investment.save!
    load_investments
  end

  private
  
    def allowed_params
      attributes = [:external_url, :heading_id, :administrator_id, :tag_list,
                    :valuation_tag_list, :incompatible, :visible_to_valuators, :selected, :not_selected, :supported,
                    :milestone_tag_list, valuator_ids: [], valuator_group_ids: []]
      [*attributes, translation_params(Budget::Investment)]
    end
end
