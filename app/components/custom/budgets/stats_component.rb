class Budgets::StatsComponent < ApplicationComponent
  def initialize(summary: false)
    @summary = summary
    @total_budgets = Budget.count
    @budgets_last_week = Budget.last_week.count
    @active_budgets = Budget.open.count
    @finished_budgets = Budget.finished.count

    participants = User.distinct
                       .joins("LEFT JOIN budget_ballots ON budget_ballots.user_id = users.id")
                       .joins("LEFT JOIN budget_investments ON budget_investments.author_id = users.id")
                       .where("budget_ballots.id IS NOT NULL OR budget_investments.id IS NOT NULL")
    @total_participants = participants.count
    @total_male_participants = participants.select { |r| r["gender"] == "male" }.count
    @total_female_participants = participants.select { |r| r["gender"] == "female" }.count
    @total_other_participants = @total_participants - @total_male_participants - @total_female_participants
    @male_percentage = percentage(@total_male_participants, @total_participants)
    @female_percentage = percentage(@total_female_participants, @total_participants)
    @other_percentage = percentage(@total_other_participants, @total_participants)

    @informing_count = Budget.informing.count
    @accepting_count = Budget.accepting.count
    @reviewing_count = Budget.reviewing.count
    @selecting_count = Budget.selecting.count
    @valuating_count = Budget.valuating.count
    @publishing_prices_count = Budget.publishing_prices.count
    @balloting_count = Budget.balloting.count
    @reviewing_ballots_count = Budget.reviewing_ballots.count
    @finished_count = Budget.finished.count

    @total_investments = Budget::Investment.count
    @total_ballots = Budget::Ballot.count
    @total_voters = Budget::Ballot.select("DISTINCT user_id").count

    @phase_distribution = calculate_phase_distribution
    @most_active_budget = find_most_active_budget
  end

  private

    def summary?
      @summary
    end

    def calculate_phase_distribution
      total = Budget.count.to_f
      return {} if total.zero?

      {
        informing: percentage(@informing_count, total),
        accepting: percentage(@accepting_count, total),
        reviewing: percentage(@reviewing_count, total),
        selecting: percentage(@selecting_count, total),
        valuating: percentage(@valuating_count, total),
        publishing_prices: percentage(@publishing_prices_count, total),
        balloting: percentage(@balloting_count, total),
        reviewing_ballots: percentage(@reviewing_ballots_count, total),
        finished: percentage(@finished_count, total)
      }
    end

    def find_most_active_budget
      Budget.joins(:investments)
            .select("budgets.*, COUNT(budget_investments.id) as investment_count")
            .group("budgets.id")
            .order("investment_count DESC")
            .first
    end

    def percentage(value, total)
      return 0 if total.zero?

      ((value.to_f / total) * 100).round(1)
    end
end
