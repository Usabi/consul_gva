
load Rails.root.join("app", "components", "admin", "menu_component.rb")

class Admin::MenuComponent
  private

    def help_texts?
      controller_name == "help_texts" && params[:help_text_id].present?
    end

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

    def help_texts_link
      [
        t("admin.menu.site_customization.help_texts"),
        admin_site_customization_help_texts_path,
        help_texts? || controller_name == "help_texts"
      ]
    end

    def site_customization_links
      link_to(t("admin.menu.title_site_customization"), "#", class: "site-customization-link") +
        link_list(
          homepage_link,
          pages_link,
          help_texts_link,
          banners_link,
          information_texts_link,
          documents_link,
          images_link,
          content_blocks_link,
          class: ("is-active" if customization? &&
                                 controller.class.module_parent != Admin::Poll::Questions::Options)
        )
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
