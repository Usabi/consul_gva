load Rails.root.join("app", "controllers", "comments_controller.rb")

class CommentsController
  private

  def build_comment
    @comment = Comment.build(@commentable, current_user, comment_params[:body],
                             comment_params[:parent_id].presence,
                             comment_params[:valuation])
    build_attached_document
    check_for_special_comments
  end

  def build_attached_document
    attachment = params.dig(:comment, :attachment)
    return if attachment.blank? || !attachment.respond_to?(:original_filename)

    @comment.documents.build(user: current_user,
                             title: attachment.original_filename,
                             attachment: attachment)
  end

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
