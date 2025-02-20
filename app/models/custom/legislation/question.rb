load Rails.root.join("app", "models", "legislation", "question.rb")

class Legislation::Question
  def all_comments
    comments.where(ancestry: nil).sort_by_supports
  end
end
