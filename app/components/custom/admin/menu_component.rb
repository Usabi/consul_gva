load Rails.root.join("app", "components", "admin", "menu_component.rb")

class Admin::MenuComponent
  private

    def default_links
      [
        (proposals_link if feature?(:proposals)),
        (debates_link if feature?(:debates)),
        comments_link,
        (polls_link if feature?(:polls)),
        (legislation_links if feature?(:legislation)),
        (budgets_link if feature?(:budgets)),
        booths_links,
        (signature_sheets_link if feature?(:signature_sheets)),
        messages_links,
        site_customization_links,
        moderated_content_links,
        profiles_links,
        stats_link,
        key_systems_link,
        settings_links,
        dashboard_links,
        (machine_learning_link if ::MachineLearning.enabled?)
      ]
    end

    def help_texts?
      controller_name == "help_texts" && params[:help_text_id].present?
    end

    def alert_messages?
      controller_name == "alert_messages" && params[:alert_message_id].present?
    end

    def legislation?
      [:councils, :processes].include?(controller_name.to_sym) || controller_name.start_with?("legislation::")
    end

    def messages_sections
      %w[bulletins newsletters emails_download admin_notifications system_emails]
    end

    def key_systems_link
      [
        t("admin.menu.key_systems"),
        admin_key_systems_path,
        controller_name == "key_systems",
        class: "key-systems-link"
      ]
    end

    def legislation_links
      section(t("admin.menu.legislation"), active: legislation?, class: "legislation-link") do
        link_list(
          legislation_link,
          councils_link,
          id: "legislation_menu"
        )
      end
    end

    def legislation_link
      [
        t("admin.menu.legislation"),
        admin_legislation_processes_path,
        legislation? && controller_name != "councils",
        class: "legislation-link"
      ]
    end

    def councils_link
      [
        t("admin.menu.legislation_councils"),
        admin_legislation_councils_path,
        controller_name == "councils",
        class: "legislation-councils-link"
      ]
    end

    def supporters_link
      [
        t("admin.menu.supporters"),
        admin_supporters_path,
        controller_name == "supporters"
      ]
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

    def alert_messages_link
      [
        t("admin.menu.site_customization.alert_messages"),
        admin_alert_messages_path,
        alert_messages? || controller_name == "alert_messages"
      ]
    end

    def bulletins_link
      [
        t("admin.menu.bulletins"),
        admin_bulletins_path,
        controller_name == "bulletins"
      ]
    end

    def messages_links
      section(t("admin.menu.messaging_users"), active: messages_menu_active?, class: "messages-link") do
        link_list(
          bulletins_link,
          newsletters_link,
          admin_notifications_link,
          system_emails_link,
          emails_download_link,
          id: "messaging_users_menu"
        )
      end
    end

    def site_customization_links
      section(t("admin.menu.title_site_customization"),
              active: customization?, class: "site-customization-link") do
        link_list(
          homepage_link,
          pages_link,
          help_texts_link,
          banners_link,
          alert_messages_link,
          information_texts_link,
          documents_link,
          images_link,
          content_blocks_link
        )
      end
    end

    def profiles_links
      section(t("admin.menu.title_profiles"), active: profiles?, class: "profiles-link") do
        link_list(
          administrators_link,
          supporters_link,
          organizations_link,
          officials_link,
          moderators_link,
          valuators_link,
          managers_link,
          (sdg_managers_link if feature?(:sdg)),
          legislations_link,
          budget_managers_link,
          users_link
        )
      end
    end
end
