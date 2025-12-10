require "rails_helper"
require "csv"

describe "Admin Organizations CSV" do
  let(:admin) { create(:administrator) }

  before { sign_in admin.user }

  describe "GET /admin/organizations.csv" do
    it "returns CSV with all organizations" do
      create_list(:organization, 3)

      get admin_organizations_path(format: :csv)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
      expect(response.headers["Content-Disposition"]).to include("organizations.csv")
    end

    it "includes organization data in CSV" do
      user = create(:user, email: "org@example.com", phone_number: "123456789")
      organization = create(:organization,
                            user: user,
                            name: "Test Organization",
                            responsible_name: "Jane Doe")

      get admin_organizations_path(format: :csv)

      csv = CSV.parse(response.body, headers: true)
      id_column = I18n.t("admin.organizations.index.list.id")
      name_column = I18n.t("admin.organizations.index.list.name")
      email_column = I18n.t("admin.organizations.index.list.email")
      phone_column = I18n.t("admin.organizations.index.list.phone_number")
      responsible_column = I18n.t("admin.organizations.index.list.responsible_name")

      org_row = csv.find { |row| row[id_column] == organization.id.to_s }

      expect(org_row).to be_present
      expect(org_row[name_column]).to eq("Test Organization")
      expect(org_row[email_column]).to eq("org@example.com")
      expect(org_row[phone_column]).to eq("123456789")
      expect(org_row[responsible_column]).to eq("Jane Doe")
    end

    it "includes organization status in CSV" do
      verified_org = create(:organization, :verified, name: "Verified Org")
      rejected_org = create(:organization, :rejected, name: "Rejected Org")
      pending_org = create(:organization, name: "Pending Org")

      get admin_organizations_path(format: :csv, filter: "all")

      csv = CSV.parse(response.body, headers: true)
      status_column = I18n.t("admin.organizations.index.list.status")
      id_column = I18n.t("admin.organizations.index.list.id")

      verified_row = csv.find { |row| row[id_column] == verified_org.id.to_s }
      rejected_row = csv.find { |row| row[id_column] == rejected_org.id.to_s }
      pending_row = csv.find { |row| row[id_column] == pending_org.id.to_s }

      expect(verified_row[status_column]).to eq(I18n.t("admin.organizations.index.verified"))
      expect(rejected_row[status_column]).to eq(I18n.t("admin.organizations.index.rejected"))
      expect(pending_row[status_column]).to eq(I18n.t("admin.organizations.index.pending"))
    end
  end

  describe "GET /admin/organizations/search.csv" do
    it "returns CSV with search results" do
      user = create(:user, email: "searchable@org.com")
      create(:organization, user: user, name: "Searchable Organization")

      get search_admin_organizations_path(format: :csv, search: "Searchable")

      expect(response).to have_http_status(:ok)
      csv = CSV.parse(response.body, headers: true)
      name_column = I18n.t("admin.organizations.index.list.name")

      expect(csv.count).to eq(1)
      expect(csv.first[name_column]).to eq("Searchable Organization")
    end
  end
end
