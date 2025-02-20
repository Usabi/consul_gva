load Rails.root.join("app", "controllers", "valuation", "base_controller.rb")

class Valuation::BaseController < ApplicationController
  private

    def verify_valuator
      raise CanCan::AccessDenied unless current_user&.valuator? || current_user&.administrator? || current_user&.budget_manager?
    end
end
