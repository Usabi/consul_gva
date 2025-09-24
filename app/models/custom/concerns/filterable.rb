load Rails.root.join("app", "models", "concerns", "filterable.rb")

module Filterable
  def self.included(base)
    base.class_eval do
      scope :by_tag, ->(tag) { where(tags: { name: tag }) }
      scope :by_id, ->(id) { where(id: id) }
      scope :by_geozone, ->(id) { where(geozone_id: id) }
      scope :by_council, ->(title) {
        joins(council: :translations)
          .where("legislation_council_translations.title = ?", title)
          .where(legislation_council_translations: { locale: I18n.locale })
      } 

    end
  end

  class_methods do
    def allowed_filter?(filter, value)
      return if value.blank?
      
      ["official_level", "date_range", "tag", "geozone", "id", "goal", "target", "council"].include?(filter)
    end
  end
end
