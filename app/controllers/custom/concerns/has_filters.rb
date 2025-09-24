load Rails.root.join("app", "controllers", "concerns", "has_filters.rb")

module HasFilters

  private

    def advance_search_present?
      params[:advanced_search].present? && params[:advanced_search].keys.map { |key| params[:advanced_search][key].present? }.uniq.include?(true)
    end
end
