load Rails.root.join("app", "controllers", "admin", "budget_investments_controller.rb")

class Admin::BudgetInvestmentsController
  before_action :load_investment, only: [:show, :edit, :update, :toggle_selection, :toggle_winner]

  def bulk_actions
    case params[:button]
    when "visible_to_valuators_bulk" then visible_to_valuators_bulk
    when "selected_bulk"             then selected_bulk
    when "winner_bulk"               then winner_bulk
    end
  end

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

    def visible_to_valuators_bulk
      ids = params[:investment_ids]
      if ids.present?
        investments = Budget::Investment.where(id: ids)
        investments.each do |investment|
          investment.update(visible_to_valuators: true) unless investment.visible_to_valuators
        end
      end
      redirect_to request.referer.presence || root_path
    end

    def selected_bulk
      ids = params[:investment_ids]
      if ids.present?
        investments = Budget::Investment.where(id: ids)
        investments.each do |investment|
          next unless investment.feasible? && investment.valuation_finished

          authorize! :toggle_selection, investment
          investment.update(selected: true) unless investment.selected
        end
      end
      redirect_to request.referer.presence || root_path
    end

    def winner_bulk
      ids = params[:investment_ids]
      if ids.present?
        investments = Budget::Investment.where(id: ids)
        investments.each do |investment|
          next unless investment.selected?

          authorize! :toggle_winner, investment
          investment.update(winner: true) unless investment.winner
        end
      end
      redirect_to request.referer.presence || root_path
    end
end
