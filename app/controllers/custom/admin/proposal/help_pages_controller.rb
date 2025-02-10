class Admin::Proposal::HelpPagesController < Admin::BaseController
  load_and_authorize_resource :proposal, class: "Proposal"
  include Admin::HelpPagesActions

  def show
    @help_text_content = help_text(Admin::ProcessesController.controller_name)
  end
end
