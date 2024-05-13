require_dependency Rails.root.join("app", "components", "layout", "admin_login_items_component")

class Layout::AdminLoginItemsComponent
  def render?
    show_admin_menu?(user) || user&.legislator? || user&.budget_manager?
  end

  private

    def admin_links
      [
        (admin_link if user.administrator?),
        (moderation_link if user.administrator? || user.moderator?),
        (valuation_link if feature?(:budgets) && (user.administrator? || user.valuator? || user.budget_manager)),
        (management_link if user.administrator? || user.manager?),
        (admin_legislation_processes_link if user.legislator?),
        (admin_budget_link if user.budget_manager?),
        (officing_link if user.poll_officer?),
        (sdg_management_link if feature?(:sdg) && (user.administrator? || user.sdg_manager?))
      ]
    end

    def admin_legislation_processes_link
      [t("layouts.header.collaborative_legislation"), admin_legislation_processes_path]
    end

    def admin_budget_link
      [t("layouts.header.budgets"), admin_budgets_path]
    end
end
