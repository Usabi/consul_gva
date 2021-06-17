require_dependency Rails.root.join("app", "controllers", "valuation", "budget_investments_controller").to_s

class Valuation::BudgetInvestmentsController < Valuation::BaseController
  def valuate
    if valid_price_params? && @investment.update(valuation_params)
      if @investment.unfeasible_email_pending?
        @investment.send_unfeasible_email
      end

      if @investment.not_selected_email_pending?
        @investment.send_not_selected_email
      end

      Activity.log(current_user, :valuate, @investment)
      notice = t("valuation.budget_investments.notice.valuate")
      redirect_to valuation_budget_budget_investment_path(@budget, @investment), notice: notice
    else
      render action: :edit
    end
  end

  private

    def restrict_access
      unless current_user.administrator? || current_user.budget_manager? || current_budget.valuating?
        raise CanCan::AccessDenied.new(I18n.t("valuation.budget_investments.not_in_valuating_phase"))
      end
    end

    def restrict_access_to_assigned_items
      return if current_user.administrator? || current_user.budget_manager? ||
                Budget::ValuatorAssignment.exists?(investment_id: params[:id],
                                                   valuator_id: current_user.valuator.id)

      raise ActionController::RoutingError.new("Not Found")
    end

    def valuation_params
      params.require(:budget_investment).permit(:price, :price_first_year, :price_explanation,
                                                :feasibility, :unfeasibility_explanation,
                                                :not_selected_explanation,
                                                :duration, :valuation_finished)
    end
end
