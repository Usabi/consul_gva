
class Admin::MenuComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "admin", "menu_component").to_s

class Admin::MenuComponent < ApplicationComponent
  
  def legislations_link
    [
      t("admin.menu.legislators"),
      admin_legislators_path,
      controller_name == "legislators"
    ]
  end

  def budget_managers_link
    [
      t("admin.menu.budget_managers"),
      admin_budget_managers_path,
      controller_name == "budget_managers"
    ]
  end
end
