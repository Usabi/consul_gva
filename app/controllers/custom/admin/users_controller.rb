load Rails.root.join("app", "controllers", "admin", "users_controller.rb")

class Admin::UsersController
  has_filters %w[active erased residence_requested], only: :index
end
