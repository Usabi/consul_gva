require_dependency Rails.root.join("app", "controllers", "concerns", "has_filters").to_s

module HasFilters

  class_methods do
    def has_filters(valid_filters, *args)
      before_action(*args) do
        @valid_filters = valid_filters.respond_to?(:call) ? valid_filters.call(self) : valid_filters
        @valid_filters.delete("relevance") if params[:search].blank? && params[:advanced_search].blank?
        @current_filter = @valid_filters.include?(params[:filter]) ? params[:filter] : @valid_filters.first
      end
    end
  end
end
