class Admin::DashboardController < Admin::BaseController
  def index
    @debates = ::Debate.limit(5)
    @polls = ::Poll.published.current_or_recounting.limit(5)
    @budgets = ::Budget.published.order(created_at: :desc).limit(3)
    @proposals = ::Proposal.limit(5)
    @preview_processes = Legislation::Process.published.active.preview_phase.order(start_date: :asc).limit(10)
    @public_processes = Legislation::Process.published.active.public_phase.order(start_date: :asc).limit(10)
  end
end
