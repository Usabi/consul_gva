require_dependency Rails.root.join("app", "models", "proposal").to_s

class Proposal

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
end
