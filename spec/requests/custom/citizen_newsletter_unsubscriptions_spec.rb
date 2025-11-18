require "rails_helper"

RSpec.describe "CitizenNewsletterUnsubscriptions" do
  describe "GET /citizen_newsletter/unsubscribe/:token" do
    it "shows unsubscription confirmation page with valid token" do
      create(:user, subscriptions_token: "valid_token")

      get citizen_newsletter_unsubscribe_path(token: "valid_token")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t("citizen_newsletter.unsubscribe.title"))
    end

    it "redirects with alert when token is invalid" do
      get citizen_newsletter_unsubscribe_path(token: "invalid_token")

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include(I18n.t("citizen_newsletter.unsubscribe.invalid_token"))
    end
  end

  describe "PATCH /citizen_newsletter/unsubscribe/:token" do
    it "unsubscribes user from all citizen newsletters" do
      user = create(:user,
                    subscriptions_token: "valid_token",
                    newsletter_debates: true,
                    newsletter_proposals: true,
                    newsletter_legislation: true)

      expect do
        patch citizen_newsletter_unsubscribe_path(token: "valid_token")
      end.to change { user.reload.newsletter_debates }.from(true).to(false)
         .and change { user.reload.newsletter_proposals }.from(true).to(false)
         .and change { user.reload.newsletter_legislation }.from(true).to(false)

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include(I18n.t("citizen_newsletter.unsubscribe.success"))
    end

    it "redirects with alert when token is invalid" do
      patch citizen_newsletter_unsubscribe_path(token: "invalid_token")

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include(I18n.t("citizen_newsletter.unsubscribe.invalid_token"))
    end
  end
end
