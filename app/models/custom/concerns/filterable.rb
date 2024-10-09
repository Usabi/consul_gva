require_dependency Rails.root.join("app", "models", "concerns", "filterable").to_s

module Filterable
  def self.included(base)
    base.class_eval do
      scope :by_tag, ->(tag) { where(tags: { name: tag }) }
      scope :by_id, ->(id) { where(id: id) }
      scope :by_geozone, ->(id) { where(geozone_id: id) }

    end
  end

  class_methods do
    def allowed_filter?(filter, value)
      return if value.blank?

      ["official_level", "date_range", "tag", "geozone", "id"].include?(filter)
    end
  end
end
