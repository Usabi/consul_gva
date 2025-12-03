require "rails_helper"
require "csv"

describe "Admin Budget Managers CSV" do
  let(:admin) { create(:administrator) }

  before { sign_in admin.user }
  describe "GET /admin/budget_managers.csv" do
    it "returns CSV with all budget managers" do
      create_list(:budget_manager, 3)

      get admin_budget_managers_path(format: :csv)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
      expect(response.headers["Content-Disposition"]).to include("budget_managers.csv")
    end
  end

  describe "GET /admin/budget_managers/search.csv" do
    it "returns CSV with search results" do
      user = create(:user, username: "searchable_budget_manager")
      create(:budget_manager, user: user)

      get search_admin_budget_managers_path(format: :csv, search: "searchable")

      expect(response).to have_http_status(:ok)
      csv = CSV.parse(response.body, headers: true)

      expect(csv.count).to eq(1)
      expect(csv.first["Username"]).to eq("searchable_budget_manager")
    end
  end
end
