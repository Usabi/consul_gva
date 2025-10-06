load Rails.root.join("app", "controllers", "admin", "base_controller.rb")

class Admin::BaseController < ApplicationController
  private

    def admin_role?
      current_user&.administrator? ||
        current_user&.legislator? ||
        current_user&.budget_manager? ||
        current_user&.supporter?
    end

    def verify_administrator
      raise CanCan::AccessDenied unless admin_role?
    end
end
