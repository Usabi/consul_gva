class Admin::Dashboard::IndexComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "admin", "dashboard", "index_component.rb")

class Admin::Dashboard::IndexComponent
  def initialize(debates:, polls:, budgets:, proposals:, preview_processes:, public_processes:)
    @debates = debates
    @polls = polls
    @budgets = budgets
    @proposals = proposals
    @preview_processes = preview_processes
    @public_processes = public_processes
    @legislation_processes = preview_processes + public_processes
  end

  def title
    t("admin.dashboard.index.title")
  end

  private

    def debates_component
      Admin::Dashboard::DebatesComponent.new(debates: @debates)
    end

    def proposals_component
      Admin::Dashboard::ProposalsComponent.new(proposals: @proposals)
    end

    def upcomming_date_component
      Admin::Dashboard::UpcomingDatesComponent.new(polls: @polls, budgets: @budgets, legislation_processes:  @legislation_processes)
    end

    def polls_component
      Admin::Dashboard::PollsComponent.new(polls: @polls)
    end

    def budgets_component
      Admin::Dashboard::BudgetsComponent.new(budgets: @budgets)
    end

    def legislation_processes_component
      Admin::Dashboard::LegislationProcessesComponent.new(
        preview_processes: @preview_processes,
        public_processes: @public_processes
      )
    end

    def guides_component
      Admin::Dashboard::GuidesComponent.new
    end
end
