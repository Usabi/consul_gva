require "rails_helper"

describe Administrator::Exporter do
  it_behaves_like "csv exporter",
                  :administrator,
                  Administrator::Exporter,
                  ["ID", "Username", "Email", "Description"]

  describe "#to_csv" do
    it "includes administrator specific data" do
      user = create(:user, username: "admin_user", email: "admin@example.com")
      administrator = create(:administrator, user: user, description: "Main admin")
      exporter = Administrator::Exporter.new([administrator])

      csv = exporter.to_csv

      expect(csv).to include("admin_user")
      expect(csv).to include("admin@example.com")
      expect(csv).to include("Main admin")
    end

    it "handles administrators without description" do
      administrator = create(:administrator, description: nil)
      exporter = Administrator::Exporter.new([administrator])

      csv = exporter.to_csv

      expect(csv).to include(administrator.user.username)
    end
  end
end
