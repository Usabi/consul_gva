require "rails_helper"
require "csv"

describe "Admin Administrators CSV" do
  let(:admin) { create(:administrator) }

  before { sign_in admin.user }

  describe "GET /admin/administrators.csv" do
    it "returns CSV with all administrators" do
      create_list(:administrator, 3)

      get admin_administrators_path(format: :csv)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
      expect(response.headers["Content-Disposition"]).to include("administrators.csv")
    end

    it "includes administrator data in CSV" do
      user = create(:user, username: "admin_user", email: "admin@example.com")
      administrator = create(:administrator, user: user, description: "Main admin")

      get admin_administrators_path(format: :csv)

      csv = CSV.parse(response.body, headers: true)
      admin_row = csv.find { |row| row["ID"] == administrator.id.to_s }

      expect(admin_row).to be_present
      expect(admin_row["Username"]).to eq("admin_user")
      expect(admin_row["Email"]).to eq("admin@example.com")
      expect(admin_row["Description"]).to eq("Main admin")
    end
  end

  describe "GET /admin/administrators/search.csv" do
    it "returns CSV with search results" do
      user = create(:user, username: "searchable_admin")
      create(:administrator, user: user)

      get search_admin_administrators_path(format: :csv, search: "searchable")

      expect(response).to have_http_status(:ok)
      csv = CSV.parse(response.body, headers: true)

      expect(csv.count).to eq(1)
      expect(csv.first["Username"]).to eq("searchable_admin")
    end
  end
end
