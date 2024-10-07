require_dependency Rails.root.join("app", "controllers", "admin", "milestone_statuses_controller").to_s

class Admin::MilestoneStatusesController
  include Translatable

  load_and_authorize_resource :status, class: "Milestone::Status"

  private

    def allowed_params
      [translation_params(Milestone::Status)]
    end
end
