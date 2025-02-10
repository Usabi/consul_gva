require_dependency Rails.root.join("app", "controllers", "admin", "poll", "polls_controller").to_s

class Admin::Poll::PollsController
  include Admin::HelpPagesActions

  def help_page
    @help_text_content = help_text(controller_name)
    render "admin/poll/polls/help_pages/show"
  end
end
