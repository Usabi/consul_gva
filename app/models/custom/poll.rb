require_dependency Rails.root.join("app", "models", "poll").to_s

class Poll
  scope :last_week, -> { where("created_at >= ?", 7.days.ago) }
end
