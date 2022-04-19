class Shared::AdvancedSearchComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "shared", "advanced_search_component").to_s

class Shared::AdvancedSearchComponent
  def debates?
    controller_path == "debates"
  end

  def categories_search_options
    options_for_select(Tag.category.order(:name).map { |i| [i.name, i.name] },
                       params[:advanced_search].try(:[], :tag))
  end
end
