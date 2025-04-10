class Admin::Dashboard::UpcomingDatesComponent < ApplicationComponent
  def initialize(polls:, budgets:, legislation_processes:)
    @polls = polls
    @budgets = budgets
    @legislation_processes = legislation_processes
  end

  private

    def upcoming_dates
      dates = []

      @polls.current.each do |poll|
        dates << {
          title: poll.name,
          date: poll.ends_at,
          description: t("admin.dashboard.index.poll_ending"),
          icon: "polls-icon",
          url: admin_poll_path(poll)
        }
      end

      @budgets.where.not(phase: "finished").find_each do |budget|
        current_phase = budget.current_phase
        if current_phase&.ends_at
          dates << {
            title: budget.name,
            date: current_phase.ends_at,
            description: t("admin.dashboard.index.budget_phase_ending", phase: budget.current_phase.name),
            icon: "budgets-icon",
            url: admin_budget_path(budget)
          }
        end
      end

      @legislation_processes.each do |process|
        if process.debate_phase.enabled? && process.debate_phase.started? && !process.debate_phase.open?
          dates << {
            title: process.title,
            date: process.debate_end_date,
            description: t("admin.dashboard.index.debate_phase_ending"),
            icon: "legislations-icon",
            url: admin_legislation_process_path(process)
          }
        end

        if process.proposals_phase.enabled? && process.proposals_phase.started? && !process.proposals_phase.open?
          dates << {
            title: process.title,
            date: process.proposals_phase_end_date,
            description: t("admin.dashboard.index.proposals_phase_ending"),
            icon: "legislations-icon",
            url: admin_legislation_process_path(process)
          }
        end

        if process.allegations_phase.enabled? && process.allegations_phase.started? && !process.allegations_phase.open?
          dates << {
            title: process.title,
            date: process.allegations_end_date,
            description: t("admin.dashboard.index.allegations_phase_ending"),
            icon: "legislations-icon",
            url: admin_legislation_process_path(process)
          }
        end
      end

      dates.sort_by { |date| date[:date] }.first(5)
    end
end
