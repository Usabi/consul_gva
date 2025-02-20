load Rails.root.join("app", "models", "comment.rb")

class Comment
  scope :not_as_admin_or_moderator, -> do
    where("administrator_id IS NULL AND legislator_id IS NULL AND budget_manager_id IS NULL").where(moderator_id: nil)
  end

  def as_administrator?
    administrator_id.present? || legislator_id.present? || budget_manager_id.present?
  end
end
