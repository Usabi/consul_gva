require_dependency Rails.root.join("app", "controllers", "admin", "stats_controller").to_s
class Admin::StatsController

  def budget_stats
    @budget = Budget.find(params[:budget_id])
    @stats = Budget::Stats.new(@budget)
    @headings = @budget.headings.sort_by_name

    authorize! :read_admin_stats, @budget, message: t("admin.stats.budgets.no_data_before_balloting_phase")

    respond_to do |format|
      format.html
      format.xlsx { render xlsx: "budget_stats", filename: "budget_stats_#{@budget.id}-#{Date.current}.xlsx" }
    end
  end
end
