module SearchCache
  extend ActiveSupport::Concern

  included do
    after_save :calculate_tsvector
  end

  def calculate_tsvector
    searchable = "(#{searchable_values_sql})"
    return if searchable == "()"

    self.class.with_hidden.where(id: id).update_all("tsv = #{searchable}")
  end

  private

    def searchable_values_sql
      searchable_values
        .select { |k, _| k.present? }
        .map { |value, weight| set_tsvector(value, weight) }
        .join(" || ")
    end

    def set_tsvector(value, weight)
      dict = quote(SearchDictionarySelector.call)
      unaccent_schema = (Rails.env.test? || Rails.env.development?) ? "unaccent" : Rails.application.secrets.unaccent_schema
      "setweight(to_tsvector(#{dict}, #{unaccent_schema}(coalesce(#{quote(strip_html(value))}, ''))), #{quote(weight)})"
    end

    def quote(value)
      ActiveRecord::Base.connection.quote(value)
    end

    def strip_html(value)
      ActionController::Base.helpers.sanitize(value, tags: [])
    end
end
