
class Layout::AdminHeaderComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "layout", "admin_header_component")

class Layout::AdminHeaderComponent
  private

    def current_legislator?
      @user&.legislator?
    end

    def current_budget_manager?
      @user&.budget_manager?
    end

    def namespaced_header_title
      if namespace == "moderation/budgets"
        t("moderation.header.title")
      elsif namespace == "management"
        t("management.dashboard.index.title")
      elsif current_legislator?
        t("admin.legislators.header.title")
      elsif current_budget_manager?
        t("admin.budget_managers.header.title")
      else
        t("#{namespace}.header.title")
      end
    end
end
