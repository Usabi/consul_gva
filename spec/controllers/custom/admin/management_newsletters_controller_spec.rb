require "rails_helper"

RSpec.describe Admin::ManagementNewslettersController do
  let(:admin) { create(:administrator) }
  let!(:newsletter) { create(:management_newsletter, status: "pending") }

  before { sign_in admin.user }

  describe "POST #create" do
    let(:newsletter_params) { attributes_for(:management_newsletter) }
    it "creates a newsletter" do
      expect do
        post :create, params: { management_newsletter: newsletter_params }
      end.to change(ManagementNewsletter, :count).by(1)
    end

    it "redirects to index" do
      post :create, params: { management_newsletter: newsletter_params }
      expect(response).to redirect_to(admin_management_newsletters_path)
    end
  end

  describe "POST #resend" do
    let(:mailer) { double("Mailer", deliver_later: true) }
    before do
      allow(Mailer).to receive(:management_newsletter).and_return(mailer)
    end

    context "pending" do
      it "calls Mailer.management_newsletter and shows notice" do
        post :resend, params: { id: newsletter.id }
        expect(Mailer).to have_received(:management_newsletter).with(newsletter)
        expect(response).to redirect_to(admin_management_newsletters_path)
        expect(flash[:notice]).to be_present
      end
    end

    context "sent" do
      let!(:newsletter) { create(:management_newsletter, status: "sent") }
      it "shows alert, does not send mail" do
        post :resend, params: { id: newsletter.id }
        expect(Mailer).not_to have_received(:management_newsletter)
        expect(response).to redirect_to(admin_management_newsletters_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "POST #update_frequency" do
    it "sets frequency when valid" do
      post :update_frequency, params: { frequency: "daily" }
      expect(Setting["management_newsletter_frequency"]).to eq("daily")
      expect(response).to redirect_to(admin_management_newsletters_path)
      expect(flash[:notice]).to be_present
    end

    it "does not set frequency when invalid" do
      post :update_frequency, params: { frequency: "monthly" }
      expect(Setting["management_newsletter_frequency"]).not_to eq("monthly")
      expect(response).to redirect_to(admin_management_newsletters_path)
      expect(flash[:alert]).to be_present
    end
  end
end
