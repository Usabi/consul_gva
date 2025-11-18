require "rails_helper"

RSpec.describe Mailer do
  describe "#management_newsletter" do
    let!(:admin) { create(:administrator) }
    let(:newsletter) { create(:management_newsletter, status: "pending") }

    it "builds the email for administrators" do
      mail = Mailer.management_newsletter(newsletter)
      expect(mail.to).to eq([admin.user.email])
      expect(mail.subject).to include(Date.current.to_s)
    end
  end

  describe "#citizen_newsletter" do
    let(:user) { create(:user, newsletter: true, newsletter_proposals: true) }
    let(:newsletter) { create(:citizen_newsletter, status: "pending") }

    before do
      user.add_subscriptions_token
    end

    it "builds the email for subscribed users" do
      mail = Mailer.citizen_newsletter(newsletter, user)
      expect(mail.to).to eq([user.email])
      expect(mail.subject).to include(I18n.l(Date.current, format: :long))
    end

    it "includes the unsubscribe token" do
      mail = Mailer.citizen_newsletter(newsletter, user)
      expect(mail.body.encoded).to include(user.subscriptions_token)
    end

    it "uses the user's locale" do
      user.update!(locale: "val")
      mail = Mailer.citizen_newsletter(newsletter, user)
      expect(mail.subject).to include("Novetats de GVA Participa")
    end
  end
end
