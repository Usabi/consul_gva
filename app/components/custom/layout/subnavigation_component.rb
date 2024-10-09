
class Layout::SubnavigationComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "layout", "subnavigation_component")

class Layout::SubnavigationComponent
  def locale
    case I18n.locale
    when :cast
      "es"
    when :val
      "va"
    else
      I18n.locale
    end
  end
end
