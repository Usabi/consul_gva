class Admin::Poll::HelpPagesController < Admin::BaseController
  load_and_authorize_resource :poll, class: "Poll"
  include Admin::HelpPagesActions

  def show
    @help_text_content = help_text(Admin::Poll::PollsController.controller_name)
  end
end
