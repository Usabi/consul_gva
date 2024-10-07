require_dependency Rails.root.join('app', 'controllers', 'budgets', 'executions_controller').to_s

class Budgets::ExecutionsController
  private

    def investments_by_heading
      base = @budget.investments.winners.apply_filters_and_search(@budget, params, @current_filter)
      base = base.joins(milestones: :translations).includes(:milestones)
      base = base.tagged_with(params[:milestone_tag]) if params[:milestone_tag].present?

      if params[:status].present?
        base = base.with_milestone_status_id(params[:status])
        base.uniq.group_by(&:heading)
      else
        base.distinct.group_by(&:heading)
      end
    end
end
