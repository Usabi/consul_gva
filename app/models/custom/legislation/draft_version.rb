load Rails.root.join("app", "models", "legislation", "draft_version.rb")

class Legislation::DraftVersion
  def all_comments
    Comment.where(commentable: annotations, ancestry: nil).sort_by_supports
  end
end
