
class Layout::FooterComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "layout", "footer_component.rb")

class Layout::FooterComponent
  delegate :layout_menu_link_to, to: :helpers
  delegate :image_path_for, to: :helpers

  def footer_logo_path(name, default)
    if SiteCustomization::Image.image_for("#{name}.png")
      image_path_for("#{name}.png")
    else
      default
    end
  end

  def footer_links
    @footer_links ||= FooterLink.visible.includes(:translations).select do |link|
      link.label.present?
    end
  end

  def footer_link_options(footer_link)
    if footer_link.url.start_with?("/")
      {}
    else
      { rel: "noopener external", target: "_blank", title: t("shared.target_blank") }
    end
  end
end
