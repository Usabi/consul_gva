load Rails.root.join("app", "controllers", "admin", "newsletters_controller.rb")

class Admin::NewslettersController
  private

    def allowed_params
      [:subject, :from, :body, segment_recipient: []]
    end
end
