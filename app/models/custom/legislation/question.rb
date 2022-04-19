require_dependency Rails.root.join("app", "models", "legislation", "question").to_s

class Legislation::Question
  def all_comments
    comments.where(ancestry: nil).sort_by_supports
  end
end
