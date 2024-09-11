class Layout::SocialComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "layout", "social_component")

class Layout::SocialComponent

  private

    def footer_content_block
      content_block("footer", I18n.locale)
    end
end
