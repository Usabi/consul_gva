require_dependency Rails.root.join("app", "models", "legislation", "proposal").to_s

class Legislation::Proposal
  def all_comments
    comments.where(ancestry: nil).sort_by_supports
  end
end
