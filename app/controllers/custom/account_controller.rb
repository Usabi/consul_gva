load Rails.root.join("app", "controllers", "account_controller.rb")

class AccountController
  private

    def allowed_params
      if @account.organization?
        [:phone_number, :email_on_comment, :email_on_comment_reply, :newsletter,
         :newsletter_debates, :newsletter_proposals, :newsletter_legislation,
         organization_attributes: [:name, :responsible_name]]
      else
        [:username, :public_activity, :public_interests, :email_on_comment,
         :email_on_comment_reply, :email_on_direct_message, :email_digest, :newsletter,
         :newsletter_debates, :newsletter_proposals, :newsletter_legislation,
         :official_position_badge, :recommended_debates, :recommended_proposals]
      end
    end
end
