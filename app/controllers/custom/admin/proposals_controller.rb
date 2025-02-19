require_dependency Rails.root.join("app", "controllers", "admin", "proposals_controller").to_s

class Admin::ProposalsController
  include Admin::HelpPagesActions

  before_action :load_proposal, except: %i[index help_page]
  has_filters %w[all], only: :index

  def index
    @proposals = ::Proposal.scoped_filter(params, @current_filter).order_filter(params)
    @proposals = Kaminari.paginate_array(@proposals) if @proposals.is_a?(Array)
    @proposals = @proposals.page(params[:page]) unless request.format.csv?
    respond_to do |format|
      format.html
      format.csv do
        send_data Proposal::Exporter.new(@proposals).to_csv,
                  filename: "proposals.csv"
      end
    end
  end

  def help_page
    @help_text_content = help_text(controller_name)
    render "admin/proposals/help_pages/show"
  end
end
