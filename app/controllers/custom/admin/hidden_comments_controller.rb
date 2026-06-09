load Rails.root.join("app", "controllers", "admin", "hidden_comments_controller.rb")

class Admin::HiddenCommentsController
  before_action :verify_moderation_access

  private

    def verify_moderation_access
      raise CanCan::AccessDenied unless current_user&.moderator? || current_user&.administrator?
    end
end
