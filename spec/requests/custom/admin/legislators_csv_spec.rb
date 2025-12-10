require "rails_helper"
require "csv"

describe "Admin Legislators CSV" do
  let(:admin) { create(:administrator) }

  before { sign_in admin.user }
  describe "GET /admin/legislators.csv" do
    it "returns CSV with all legislators" do
      create_list(:legislator, 3)

      get admin_legislators_path(format: :csv)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
      expect(response.headers["Content-Disposition"]).to include("legislators.csv")
    end

    it "includes legislator data in CSV" do
      user = create(:user, username: "legislator_user", email: "legislator@example.com")
      legislator = create(:legislator, user: user, description: "Regional")

      get admin_legislators_path(format: :csv)

      csv = CSV.parse(response.body, headers: true)
      legislator_row = csv.find { |row| row["ID"] == legislator.id.to_s }

      expect(legislator_row).to be_present
      expect(legislator_row["Username"]).to eq("legislator_user")
      expect(legislator_row["Description"]).to eq("Regional")
    end
  end

  describe "GET /admin/legislators/search.csv" do
    it "returns CSV with search results" do
      user = create(:user, username: "searchable_legislator")
      create(:legislator, user: user)

      get search_admin_legislators_path(format: :csv, search: "searchable")

      expect(response).to have_http_status(:ok)
      csv = CSV.parse(response.body, headers: true)

      expect(csv.count).to eq(1)
      expect(csv.first["Username"]).to eq("searchable_legislator")
    end
  end
end
