require_dependency Rails.root.join("app", "controllers", "admin", "newsletters_controller").to_s

class Admin::NewslettersController
  private

    def allowed_params
      [:subject, :from, :body, segment_recipient: []]
    end
end
