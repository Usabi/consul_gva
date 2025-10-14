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
end
