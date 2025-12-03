require "rails_helper"

describe Legislator::Exporter do
  it_behaves_like "csv exporter",
                  :legislator,
                  Legislator::Exporter,
                  ["ID", "Username", "Email", "Description"]

  describe "#to_csv" do
    it "includes legislator specific data" do
      user = create(:user, username: "legislator_user", email: "legislator@example.com")
      legislator = create(:legislator, user: user, description: "Regional legislator")
      exporter = Legislator::Exporter.new([legislator])

      csv = exporter.to_csv

      expect(csv).to include("legislator_user")
      expect(csv).to include("legislator@example.com")
      expect(csv).to include("Regional legislator")
    end
  end
end
