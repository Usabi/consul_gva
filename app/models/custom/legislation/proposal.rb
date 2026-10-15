load Rails.root.join("app", "models", "legislation", "proposal.rb")

class Legislation::Proposal
  scope :last_week, -> { where("created_at >= ?", 7.days.ago) }

  def editable?
    total_votes.zero? && process.proposals_phase.open? && process.end_date >= Date.current
  end

  def all_comments
    comments.where(ancestry: nil).sort_by_supports
  end
end
