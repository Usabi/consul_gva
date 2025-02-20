class Debates::FormComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "debates", "form_component.rb")

class Debates::FormComponent
  use_helpers :suggest_data, :geozone_select_options
end
