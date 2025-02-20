load Rails.root.join("app", "controllers", "comments_controller.rb")

class CommentsController
  private

  def check_for_special_comments
    if administrator_comment?
      if current_user.legislator?
        @comment.legislator_id = current_user.legislator.id
      elsif current_user.budget_manager?
        @comment.budget_manager_id = current_user.budget_manager.id
      else
        @comment.administrator_id = current_user.administrator.id
      end
    elsif moderator_comment?
      @comment.moderator_id = current_user.moderator.id
    end
  end
end
