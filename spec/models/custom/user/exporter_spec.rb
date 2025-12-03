require "rails_helper"

describe User::Exporter do
  it_behaves_like "csv exporter",
                  :user,
                  User::Exporter,
                  [
                    I18n.t("activerecord.attributes.user.id"),
                    I18n.t("admin.users.columns.name"),
                    I18n.t("admin.users.columns.email"),
                    I18n.t("admin.users.columns.document_number"),
                    I18n.t("admin.users.columns.roles"),
                    I18n.t("admin.users.columns.verification_level"),
                    I18n.t("admin.users.columns.activation_status"),
                    I18n.t("admin.users.columns.postal_code"),
                    I18n.t("admin.users.columns.services_results"),
                    I18n.t("activerecord.attributes.user.created_at")
                  ]

  describe "#to_csv" do
    it "includes user specific data" do
      user = create(:user, username: "john_doe", email: "john@example.com", document_number: "12345678")
      exporter = User::Exporter.new([user])

      csv = exporter.to_csv

      expect(csv).to include("john_doe")
      expect(csv).to include("john@example.com")
      expect(csv).to include("12345678")
    end

    it "includes user roles" do
      user = create(:user)
      create(:administrator, user: user)
      exporter = User::Exporter.new([user])

      csv = exporter.to_csv

      expect(csv).to include(I18n.t("admin.users.index.administrator"))
    end

    it "includes activation status" do
      user = create(:user, confirmed_at: Time.current)
      exporter = User::Exporter.new([user])

      csv = exporter.to_csv

      expect(csv).to include(I18n.t("admin.users.account.active_status"))
    end

    it "formats created_at date correctly" do
      user = create(:user)
      exporter = User::Exporter.new([user])

      csv = exporter.to_csv

      expect(csv).to include(I18n.l(user.created_at, format: :datetime))
    end
  end
end
