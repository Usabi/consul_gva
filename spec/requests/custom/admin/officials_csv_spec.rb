require "rails_helper"
require "csv"

describe "Admin Officials CSV" do
  let(:admin) { create(:administrator) }

  before do
    # Ensure admin user is not an official
    admin.user.update!(official_level: 0)
    sign_in admin.user
  end

  describe "GET /admin/officials.csv" do
    it "returns CSV with all officials" do
      create_list(:user, 3, official_level: 1)

      get admin_officials_path(format: :csv)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
      expect(response.headers["Content-Disposition"]).to include("officials.csv")
    end

    it "includes official data in CSV" do
      official = create(:user, username: "official_user", official_level: 2, official_position: "Mayor")

      get admin_officials_path(format: :csv)

      csv = CSV.parse(response.body, headers: true)
      id_column = I18n.t("activerecord.attributes.user.id")
      username_column = I18n.t("activerecord.attributes.user.username")
      position_column = I18n.t("activerecord.attributes.user.official_position")
      level_column = I18n.t("activerecord.attributes.user.official_level")

      official_row = csv.find { |row| row[id_column] == official.id.to_s }

      expect(official_row).to be_present
      expect(official_row[username_column]).to eq("official_user")
      expect(official_row[position_column]).to eq("Mayor")
      expect(official_row[level_column]).to eq("2")
    end
  end

  describe "GET /admin/officials/search.csv" do
    it "returns CSV with search results" do
      create(:user, username: "searchable_official", official_level: 1)

      get search_admin_officials_path(format: :csv, search: "searchable")

      expect(response).to have_http_status(:ok)
      csv = CSV.parse(response.body, headers: true)
      username_column = I18n.t("activerecord.attributes.user.username")

      expect(csv.count).to eq(1)
      expect(csv.first[username_column]).to eq("searchable_official")
    end
  end
end
