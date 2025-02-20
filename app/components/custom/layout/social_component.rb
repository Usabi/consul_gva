class Layout::SocialComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "layout", "social_component.rb")

class Layout::SocialComponent

  private

    def footer_content_block
      content_block("footer", I18n.locale)
    end
end
