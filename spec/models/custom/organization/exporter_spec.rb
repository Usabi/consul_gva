require "rails_helper"

describe Organization::Exporter do
  it_behaves_like "csv exporter",
                  :organization,
                  Organization::Exporter,
                  [
                    I18n.t("admin.organizations.index.list.id"),
                    I18n.t("admin.organizations.index.list.name"),
                    I18n.t("admin.organizations.index.list.email"),
                    I18n.t("admin.organizations.index.list.phone_number"),
                    I18n.t("admin.organizations.index.list.responsible_name"),
                    I18n.t("admin.organizations.index.list.status")
                  ]

  describe "#to_csv" do
    it "includes verified status" do
      organization = create(:organization, :verified, name: "Verified Org")
      exporter = Organization::Exporter.new([organization])

      csv = exporter.to_csv

      expect(csv).to include("Verified Org")
      expect(csv).to include(I18n.t("admin.organizations.index.verified"))
    end

    it "includes rejected status" do
      organization = create(:organization, :rejected, name: "Rejected Org")
      exporter = Organization::Exporter.new([organization])

      csv = exporter.to_csv

      expect(csv).to include("Rejected Org")
      expect(csv).to include(I18n.t("admin.organizations.index.rejected"))
    end

    it "includes pending status" do
      organization = create(:organization, name: "Pending Org")
      exporter = Organization::Exporter.new([organization])

      csv = exporter.to_csv

      expect(csv).to include("Pending Org")
      expect(csv).to include(I18n.t("admin.organizations.index.pending"))
    end

    it "includes all organization fields" do
      user = create(:user, email: "test@org.com", phone_number: "123456789")
      organization = create(:organization,
                            user: user,
                            name: "Test Org",
                            responsible_name: "John Doe")
      exporter = Organization::Exporter.new([organization])

      csv = exporter.to_csv

      expect(csv).to include("Test Org")
      expect(csv).to include("test@org.com")
      expect(csv).to include("123456789")
      expect(csv).to include("John Doe")
    end
  end
end
