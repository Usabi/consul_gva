
require_dependency Rails.root.join("app", "components", "admin", "menu_component").to_s

class Admin::MenuComponent
  private

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

    def profiles_links
      link_to(t("admin.menu.title_profiles"), "#", class: "profiles-link") +
        link_list(
          administrators_link,
          organizations_link,
          officials_link,
          moderators_link,
          valuators_link,
          managers_link,
          (sdg_managers_link if feature?(:sdg)),
          legislations_link,
          budget_managers_link,
          users_link,
          class: ("is-active" if profiles?)
        )
    end
end
