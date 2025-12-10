require "rails_helper"
require "csv"

describe "Admin Users CSV" do
  let(:admin) { create(:administrator) }

  before { sign_in admin.user }

  describe "GET /admin/users.csv" do
    it "returns CSV with all users" do
      create_list(:user, 3)

      get admin_users_path(format: :csv)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
      expect(response.headers["Content-Disposition"]).to include("users.csv")
    end

    it "includes user data in CSV" do
      create(:user, username: "test_user", email: "test@example.com")

      get admin_users_path(format: :csv)

      csv = CSV.parse(response.body, headers: true)
      name_column = I18n.t("admin.users.columns.name")
      email_column = I18n.t("admin.users.columns.email")

      user_row = csv.find { |row| row[email_column] == "test@example.com" }

      expect(user_row).to be_present
      expect(user_row[name_column]).to eq("test_user")
      expect(user_row[email_column]).to eq("test@example.com")
    end

    it "respects search filter" do
      create(:user, username: "matching_user")
      create(:user, username: "other_user")

      get admin_users_path(format: :csv, search: "matching")

      csv = CSV.parse(response.body, headers: true)
      name_column = I18n.t("admin.users.columns.name")

      expect(csv.count).to eq(1)
      expect(csv.first[name_column]).to eq("matching_user")
    end

    it "exports all records without pagination" do
      create_list(:user, 25)

      get admin_users_path(format: :csv)

      csv = CSV.parse(response.body, headers: true)

      # Should export 25 created users + 1 admin user = 26 total
      expect(csv.count).to eq(26)
    end
  end
end
