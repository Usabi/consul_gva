class Support::MenuComponent < ApplicationComponent
  include LinkListHelper
  use_helpers :can?

  def links
    if Rails.application.multitenancy_management_mode?
      multitenancy_management_links
    else
      default_links
    end
  end

  private

    def default_links
      [
        (legislation_links if feature?(:legislation)),
        profiles_links,
        key_systems_link
      ]
    end

    def profiles?
      %w[users].include?(controller_name)
    end

    def legislation?
      [:processes].include?(controller_name.to_sym) || controller_name.start_with?("legislation::")
    end

    def users_link
      [
        t("admin.menu.users"),
        admin_users_path,
        controller_name == "users"
      ]
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

    def legislations_link
      [
        t("admin.menu.legislators"),
        admin_legislators_path,
        controller_name == "legislators"
      ]
    end

    def profiles_links
      section(t("admin.menu.title_profiles"), active: profiles?, class: "profiles-link") do
        link_list(
          users_link
        )
      end
    end

    def section(title, **, &content)
      section_opener(title, **) + content.call
    end

    def section_opener(title, active:, **options)
      button_tag(title, { type: "button", disabled: "disabled", "aria-expanded": active }.merge(options))
    end
end
