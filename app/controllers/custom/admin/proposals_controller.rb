load Rails.root.join("app", "controllers", "admin", "proposals_controller.rb")

class Admin::ProposalsController
  include Admin::HelpPagesActions

  before_action :load_proposal, except: %i[index help_page]

  def index
    @proposals = ::Proposal.all.accessible_by(current_ability)
                           .page(params[:page])
  end

  def help_page
    @help_text_content = help_text(controller_name)
    render "admin/proposals/help_pages/show"
  end
end
