load Rails.root.join("app", "controllers", "users_controller.rb")

class UsersController < ApplicationController
  def users_count
    respond_to do |format|
      format.any { render json: { count: User.count }, content_type: "application/json" }
    end
  end
end
