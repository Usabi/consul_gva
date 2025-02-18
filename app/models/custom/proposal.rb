require_dependency Rails.root.join("app", "models", "proposal").to_s

class Proposal
  SORTING_OPTIONS = { id: "id", supports: "cached_votes_up", created_at: "created_at" }.freeze

  scope :sort_by_id,               -> { order("id DESC") }
  scope :sort_by_supports,         -> { order("cached_votes_up DESC") }
  scope :by_tag,                   ->(tag_name) { tagged_with(tag_name).distinct }

  def self.sort_by_title
    all.sort_by(&:title)
  end

  def self.search_by_title_or_id(title_or_id)
    with_joins = with_translations(Globalize.fallbacks(I18n.locale)).joins(:author)

    if title_or_id.to_s.match?(/^\d+$/)  # Verifica si es un número
      with_joins.where("proposals.id = :query OR
                        users.username ILIKE :like_query OR
                        proposal_translations.title ILIKE :like_query",
                       query: title_or_id.to_i, like_query: "%#{title_or_id}%")
    else
      with_joins.where("users.username ILIKE :like_query OR
                        proposal_translations.title ILIKE :like_query",
                       like_query: "%#{title_or_id}%")
    end
  end

  def self.proposals_orders(user)
    orders = %w[created_at hot_score confidence_score relevance archival_date]
    orders << "recommendations" if Setting["feature.user.recommendations_on_proposals"] && user&.recommended_proposals
    orders
  end

  def self.for_summary
    summary = {}
    categories = Tag.category_names.sort
    geozones   = Geozone.names.sort

    groups = categories + geozones
    groups.each do |group|
      summary[group] = search(group).sort_by_confidence_score.limit(3)
    end
    summary
  end

  def self.scoped_filter(params, current_filter)
    results = Proposal.all

    if params[:min_total_supports].present?
      results = results.where("cached_votes_up >= ?", params[:min_total_supports])
    end
    if params[:max_total_supports].present?
      results = results.where("cached_votes_up <= ?", params[:max_total_supports])
    end

    results = results.by_tag(params[:tag_name])               if params[:tag_name].present?
    results = results.by_goal(params[:goal])             if params[:goal].present?
    results = results.by_target(params[:target])         if params[:target].present?

    results = results.search_by_title_or_id(params[:title_or_id].strip) if params[:title_or_id]
    results = advanced_filters(params, results) if params[:advanced_filters].present?
    results = results.send(current_filter) if current_filter.present?
  end

  def self.advanced_filters(params, results)
    ids = []
    ids += results.where(selected: true).ids if params[:advanced_filters].include?("selected")
    results = results.where(id: ids) if ids.any?
    results
  end

  def self.order_filter(params)
    sorting_key = params[:sort_by]&.downcase&.to_sym
    allowed_sort_option = SORTING_OPTIONS[sorting_key]
    direction = params[:direction] == "desc" ? "desc" : "asc"

    if allowed_sort_option.present?
      order("#{allowed_sort_option} #{direction}")
    elsif sorting_key == :title
      direction == "asc" ? sort_by_title : sort_by_title.reverse
    else
      order(id: :desc)
    end
  end
end
