class Shared::AdvancedSearchComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "shared", "advanced_search_component.rb")

class Shared::AdvancedSearchComponent
  def debates?
    controller_path == "debates"
  end

  def proposals?
    controller_path == "proposals"
  end

  def processes?
    controller_path == "legislation/processes"
  end

  def categories_search_options
    options_for_select(Tag.category.order(:name).map { |i| [i.name, i.name] },
                       params[:advanced_search].try(:[], :tag))
  end

  def geozones_search_options
    options_for_select(Geozone.order(name: :asc).map { |g| [g.name, g.id] },
                       params[:advanced_search].try(:[], :geozone))
  end

  def council_options
    councils = Legislation::Council.active
                                   .with_translations(I18n.locale)
                                   .order(:title)
                                   .distinct
    options_for_select(councils.map { |c| [c.title, c.title] },
                       params[:advanced_search].try(:[], :council))
  end
end
