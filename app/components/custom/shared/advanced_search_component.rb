class Shared::AdvancedSearchComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "shared", "advanced_search_component").to_s

class Shared::AdvancedSearchComponent
  def debates?
    controller_path == "debates"
  end

  def proposals?
    controller_path == "proposals"
  end

  def categories_search_options
    options_for_select(Tag.category.order(:name).map { |i| [i.name, i.name] },
                       params[:advanced_search].try(:[], :tag))
  end

  def geozones_search_options
    options_for_select(Geozone.order(name: :asc).map { |g| [g.name, g.id] },
                       params[:advanced_search].try(:[], :geozone))
  end
end
