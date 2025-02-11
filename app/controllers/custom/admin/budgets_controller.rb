require_dependency Rails.root.join("app", "controllers", "admin", "budgets_controller").to_s

class Admin::BudgetsController
  include Admin::HelpPagesActions

  has_filters %w[all open finished help_page], only: :index

  def index
    if @current_filter == "help_page"
      @help_text_content = help_text(controller_name)
      render :help_page
    else
      @budgets = Budget.send(@current_filter).order(created_at: :desc).page(params[:page])
    end
  end
end
