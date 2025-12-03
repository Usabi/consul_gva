require "rails_helper"
require "csv"

describe "Admin Supporters CSV" do
  let(:admin) { create(:administrator) }

  before { sign_in admin.user }
  describe "GET /admin/supporters.csv" do
    it "returns CSV with all supporters" do
      create_list(:supporter, 3)

      get admin_supporters_path(format: :csv)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
      expect(response.headers["Content-Disposition"]).to include("supporters.csv")
    end

    it "includes supporter data in CSV" do
      user = create(:user, username: "supporter_user", email: "supporter@example.com")
      supporter = create(:supporter, user: user, description: "Verified")

      get admin_supporters_path(format: :csv)

      csv = CSV.parse(response.body, headers: true)
      supporter_row = csv.find { |row| row["ID"] == supporter.id.to_s }

      expect(supporter_row).to be_present
      expect(supporter_row["Username"]).to eq("supporter_user")
      expect(supporter_row["Description"]).to eq("Verified")
    end
  end

  describe "GET /admin/supporters/search.csv" do
    it "returns CSV with search results" do
      user = create(:user, username: "searchable_supporter")
      create(:supporter, user: user)

      get search_admin_supporters_path(format: :csv, search: "searchable")

      expect(response).to have_http_status(:ok)
      csv = CSV.parse(response.body, headers: true)

      expect(csv.count).to eq(1)
      expect(csv.first["Username"]).to eq("searchable_supporter")
    end
  end
end
