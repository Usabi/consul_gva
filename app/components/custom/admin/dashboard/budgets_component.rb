class Admin::Dashboard::BudgetsComponent < ApplicationComponent
  def initialize(budgets:)
    @budgets = budgets
  end

  private

    def active_budgets
      @budgets.where.not(phase: "finished").order(created_at: :desc).limit(3)
    end
end
