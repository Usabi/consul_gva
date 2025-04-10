load Rails.root.join("app", "models", "poll.rb")

class Poll
  scope :last_week, -> { where("created_at >= ?", 7.days.ago) }
end
