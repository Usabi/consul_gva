
class Layout::FooterComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "layout", "footer_component")

class Layout::FooterComponent
  delegate :layout_menu_link_to, to: :helpers

end
