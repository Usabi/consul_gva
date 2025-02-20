load Rails.root.join("app", "controllers", "admin", "budgets_controller.rb")

class Admin::BudgetsController
  include Admin::HelpPagesActions

  before_action :load_budget, except: %w[index help_page]

  def help_page
    @help_text_content = help_text(controller_name)
    render "admin/budgets/help_pages/show"
  end
end
