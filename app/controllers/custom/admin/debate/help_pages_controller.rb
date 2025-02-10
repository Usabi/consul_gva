class Admin::Debate::HelpPagesController < Admin::BaseController
  load_and_authorize_resource :debate, class: "Debate"
  include Admin::HelpPagesActions

  def show
    @help_text_content = help_text(Admin::DebatesController.controller_name)
  end
end
