load Rails.root.join("app", "controllers", "admin", "base_controller.rb")

class Admin::BaseController < ApplicationController
  private

    def verify_administrator
      raise CanCan::AccessDenied unless current_user&.administrator? || current_user&.legislator? || current_user&.budget_manager?
    end
end
