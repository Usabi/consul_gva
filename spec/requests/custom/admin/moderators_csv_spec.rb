require "rails_helper"
require "csv"

describe "Admin Moderators CSV" do
  let(:admin) { create(:administrator) }

  before { sign_in admin.user }
  describe "GET /admin/moderators.csv" do
    it "returns CSV with all moderators" do
      create_list(:moderator, 3)

      get admin_moderators_path(format: :csv)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
      expect(response.headers["Content-Disposition"]).to include("moderators.csv")
    end
  end

  describe "GET /admin/moderators/search.csv" do
    it "returns CSV with search results" do
      user = create(:user, username: "searchable_moderator")
      create(:moderator, user: user)

      get search_admin_moderators_path(format: :csv, search: "searchable")

      expect(response).to have_http_status(:ok)
      csv = CSV.parse(response.body, headers: true)

      expect(csv.count).to eq(1)
      expect(csv.first["Username"]).to eq("searchable_moderator")
    end
  end
end
