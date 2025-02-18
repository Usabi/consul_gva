require_dependency Rails.root.join("app", "controllers", "admin", "proposals_controller").to_s

class Admin::ProposalsController
  include Admin::HelpPagesActions

  before_action :load_proposal, except: %i[index help_page]

  def index
    @proposals = ::Proposal.order_filter(params)
    @proposals = Kaminari.paginate_array(@proposals) if @proposals.is_a?(Array)
    @proposals = @proposals.page(params[:page])
  end

  def help_page
    @help_text_content = help_text(controller_name)
    render "admin/proposals/help_pages/show"
  end
end
