class Admin::Legislation::HelpPagesController < Admin::Legislation::BaseController
  load_and_authorize_resource :process, class: "Legislation::Process"
  include Admin::HelpPagesActions

  def show
    @help_text_content = help_text(Admin::Legislation::ProcessesController.controller_name)
  end
end
