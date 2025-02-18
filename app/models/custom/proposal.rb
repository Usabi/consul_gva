require_dependency Rails.root.join("app", "models", "proposal").to_s

class Proposal
  SORTING_OPTIONS = { id: "id", supports: "cached_votes_up", created_at: "created_at" }.freeze

  scope :sort_by_id,               -> { order("id DESC") }
  scope :sort_by_supports,         -> { order("cached_votes_up DESC") }

  def self.sort_by_title
    all.sort_by(&:title)
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

  def self.order_filter(params)
    sorting_key = params[:sort_by]&.downcase&.to_sym
    allowed_sort_option = SORTING_OPTIONS[sorting_key]
    direction = params[:direction] == "desc" ? "desc" : "asc"

    if allowed_sort_option.present?
      order("#{allowed_sort_option} #{direction}")
    elsif sorting_key == :title
      direction == "asc" ? sort_by_title : sort_by_title.reverse
    else
      order(created_at: :desc).order(id: :desc)
    end
  end
end
