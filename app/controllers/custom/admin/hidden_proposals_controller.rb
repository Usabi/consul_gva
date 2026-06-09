load Rails.root.join("app", "controllers", "admin", "hidden_proposals_controller.rb")

class Admin::HiddenProposalsController
  before_action :verify_moderation_access

  private

    def verify_moderation_access
      raise CanCan::AccessDenied unless current_user&.moderator? || current_user&.administrator?
    end
end
