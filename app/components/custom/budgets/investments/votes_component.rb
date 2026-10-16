class Budgets::Investments::VotesComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "budgets", "investments", "votes_component.rb")

class Budgets::Investments::VotesComponent
  delegate :progress_bar_percentage_investment, :supports_percentage_investment, to: :helpers

  def show_progress_bar?
    investment.heading.present? &&
      investment.heading.min_supports.present? &&
      investment.heading.min_supports > 0
  end

  def min_supports
    investment.heading&.min_supports || 0
  end
end
