require_dependency Rails.root.join("app", "models", "legislation", "draft_version").to_s

class Legislation::DraftVersion
  def all_comments
    Comment.where(commentable: annotations, ancestry: nil).sort_by_supports
  end
end
