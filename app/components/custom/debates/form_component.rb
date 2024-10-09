class Debates::FormComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "debates", "form_component").to_s

class Debates::FormComponent
  use_helpers :suggest_data, :geozone_select_options
end
