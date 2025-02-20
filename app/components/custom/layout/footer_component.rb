
class Layout::FooterComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "layout", "footer_component.rb")

class Layout::FooterComponent
  delegate :layout_menu_link_to, to: :helpers

end
