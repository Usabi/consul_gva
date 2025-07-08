require_dependency Rails.root.join("app", "models", "poll").to_s

class Poll
  include Filterable
  include Taggable
  include Searchable

  SORTING_OPTIONS = { id: "id", starts_at: "starts_at", ends_at: "ends_at" }.freeze

  scope :last_week, -> { where("created_at >= ?", 7.days.ago) }
  def self.sort_by_name(direction = :asc)
    with_translations(Globalize.fallbacks(I18n.locale))
      .select("polls.*, poll_translations.name")
      .order("poll_translations.name #{direction}")

  end

  def self.search_by_name_or_id(name_or_id)
      with_joins = with_translations(Globalize.fallbacks(I18n.locale))

      with_joins.where(id: name_or_id)
                .or(with_joins.where("poll_translations.name ILIKE ?", "%#{name_or_id}%"))
  end

  def self.scoped_filter(params, current_filter, advanced_search_terms)
    results = Poll
    results = results.filter_by(advanced_search_terms) if advanced_search_terms.present?

    results = results.by_tag(params[:tag_name])          if params[:tag_name].present?
    results = results.by_goal(params[:goal])             if params[:goal].present?
    results = results.by_target(params[:target])         if params[:target].present?

    results = results.search_by_name_or_id(params[:name_or_id].strip) if params[:name_or_id]
    results = results.send(current_filter) if current_filter.present?
    results
  end

  def self.order_filter(params)
    sorting_key = params[:sort_by]&.downcase&.to_sym
    allowed_sort_option = SORTING_OPTIONS[sorting_key]
    direction = params[:direction] == "desc" ? "desc" : "asc"

    if sorting_key == :name
      sort_by_name(direction)
    elsif allowed_sort_option.present?
      order("#{allowed_sort_option} #{direction}")
    else
      order(id: :desc)
    end

  end

  def status
    I18n.t("admin.polls.status.#{current? ? 'open' : 'closed'}")
  end
end
