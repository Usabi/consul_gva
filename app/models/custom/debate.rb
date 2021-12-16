require_dependency Rails.root.join("app", "models", "debate").to_s

class Debate
  def self.debates_orders(user)
    orders = %w[created_at hot_score confidence_score relevance]
    orders << "recommendations" if Setting["feature.user.recommendations_on_debates"] && user&.recommended_debates
    orders
  end
end
