require "rails_helper"

RSpec.describe "Admin::ManagementNewsletters" do
  let(:admin) { create(:administrator) }
  let!(:newsletter) { create(:management_newsletter, status: "pending") }

  before { sign_in admin.user }

  describe "GET /admin/management_newsletters" do
    it "renders the index" do
      get admin_management_newsletters_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(newsletter.status.upcase_first)
    end
  end

  describe "GET /admin/management_newsletters/:id" do
    it "shows the requested newsletter" do
      get admin_management_newsletter_path(newsletter)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(newsletter.id.to_s)
      expect(response.body).to include(newsletter.status.upcase_first)
    end
  end

  describe "POST /admin/management_newsletters" do
    it "creates a newsletter and redirects" do
      expect do
        post admin_management_newsletters_path,
             params: { management_newsletter: { status: "pending" }}
      end.to change(ManagementNewsletter, :count).by(1)
      expect(response).to redirect_to(admin_management_newsletters_path)
    end
  end

  describe "POST /admin/management_newsletters/:id/resend" do
    before { allow(Mailer).to receive(:management_newsletter).and_return(double(deliver_later: true)) }

    it "resends newsletter if pending" do
      post resend_admin_management_newsletter_path(newsletter)
      expect(Mailer).to have_received(:management_newsletter).with(newsletter)
      follow_redirect!
      expect(response.body).to include(I18n.t("admin.management_newsletters.resend.success"))
    end

    it "does not resend if sent" do
      newsletter.update!(status: "sent")
      post resend_admin_management_newsletter_path(newsletter)
      expect(Mailer).not_to have_received(:management_newsletter)
      follow_redirect!
      expect(response.body).to include(I18n.t("admin.management_newsletters.resend.error"))
    end
  end

  describe "POST /admin/management_newsletters/update_frequency" do
    context "with a valid frequency" do
      it "updates the configuration and redirects with notice" do
        expect do
          post update_frequency_admin_management_newsletters_path, params: { frequency: "daily" }
        end.to change { Setting["management_newsletter_frequency"] }.to("daily")

        expect(response).to redirect_to(admin_management_newsletters_path)
        follow_redirect!
        expect(response.body).to include(I18n.t("admin.management_newsletters.configuration.updated"))
      end
    end

    context "with an invalid frequency" do
      it "does not update and redirects with alert" do
        Setting["management_newsletter_frequency"] = "weekly"

        expect do
          post update_frequency_admin_management_newsletters_path, params: { frequency: "monthly" }
        end.not_to change { Setting["management_newsletter_frequency"] }

        expect(response).to redirect_to(admin_management_newsletters_path)
        follow_redirect!
        expect(response.body).to include(I18n.t("admin.management_newsletters.configuration.invalid"))
      end
    end
  end
end
