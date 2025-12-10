require "rails_helper"

describe Supporter::Exporter do
  it_behaves_like "csv exporter",
                  :supporter,
                  Supporter::Exporter,
                  ["ID", "Username", "Email", "Description"]

  describe "#to_csv" do
    it "includes supporter specific data" do
      user = create(:user, username: "supporter_user", email: "supporter@example.com")
      supporter = create(:supporter, user: user, description: "Verified supporter")
      exporter = Supporter::Exporter.new([supporter])

      csv = exporter.to_csv

      expect(csv).to include("supporter_user")
      expect(csv).to include("supporter@example.com")
      expect(csv).to include("Verified supporter")
    end
  end
end
