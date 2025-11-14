require "rails_helper"

RSpec.describe CitizenNewsletterUnsubscriptionsController do
  describe "GET #show" do
    context "with valid token" do
      it "returns success status" do
        create(:user, subscriptions_token: "valid_token")

        get :show, params: { token: "valid_token" }

        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid token" do
      it "redirects to root with alert" do
        get :show, params: { token: "invalid_token" }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t("citizen_newsletter.unsubscribe.invalid_token"))
      end
    end
  end

  describe "PATCH #update" do
    context "with valid token" do
      it "unsubscribes user from all citizen newsletters" do
        user = create(:user,
                      subscriptions_token: "valid_token",
                      newsletter_debates: true,
                      newsletter_proposals: true,
                      newsletter_legislation: true)

        expect do
          patch :update, params: { token: "valid_token" }
        end.to change { user.reload.newsletter_debates }.from(true).to(false)
           .and change { user.reload.newsletter_proposals }.from(true).to(false)
           .and change { user.reload.newsletter_legislation }.from(true).to(false)

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t("citizen_newsletter.unsubscribe.success"))
      end
    end

    context "with invalid token" do
      it "redirects to root with alert and does not update any user" do
        user = create(:user,
                      subscriptions_token: "valid_token",
                      newsletter_debates: true,
                      newsletter_proposals: true,
                      newsletter_legislation: true)

        expect do
          patch :update, params: { token: "invalid_token" }
        end.not_to change { user.reload.newsletter_debates }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t("citizen_newsletter.unsubscribe.invalid_token"))
      end
    end
  end
end
