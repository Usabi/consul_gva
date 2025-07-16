load Rails.root.join("app", "controllers", "admin", "poll", "polls_controller.rb")

class Admin::Poll::PollsController
  include CommentableActions
  include Admin::HelpPagesActions

  def help_page
    @help_text_content = help_text(controller_name)
    render "admin/poll/polls/help_pages/show"
  end

  has_filters %w[all current expired], only: :index

  def index
    @polls = ::Poll.not_budget.created_by_admin.scoped_filter(params, @current_filter, @advanced_search_terms).order_filter(params)
    @polls = Kaminari.paginate_array(@polls) if @polls.is_a?(Array)
    @polls = @polls.page(params[:page])
    respond_to do |format|
      format.html
    end
  end
end
