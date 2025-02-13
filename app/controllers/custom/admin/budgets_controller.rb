require_dependency Rails.root.join("app", "controllers", "admin", "budgets_controller").to_s

class Admin::BudgetsController
  include Admin::HelpPagesActions

  before_action :load_budget, except: %w[index help_page]

  def help_page
    @help_text_content = help_text(controller_name)
    render "admin/budgets/help_pages/show"
  end
end
