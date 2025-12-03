require "rails_helper"
require "csv"

describe "Admin Managers CSV" do
  let(:admin) { create(:administrator) }

  before { sign_in admin.user }
  describe "GET /admin/managers.csv" do
    it "returns CSV with all managers" do
      create_list(:manager, 3)

      get admin_managers_path(format: :csv)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
      expect(response.headers["Content-Disposition"]).to include("managers.csv")
    end
  end

  describe "GET /admin/managers/search.csv" do
    it "returns CSV with search results" do
      user = create(:user, username: "searchable_manager")
      create(:manager, user: user)

      get search_admin_managers_path(format: :csv, search: "searchable")

      expect(response).to have_http_status(:ok)
      csv = CSV.parse(response.body, headers: true)

      expect(csv.count).to eq(1)
      expect(csv.first["Username"]).to eq("searchable_manager")
    end
  end
end
