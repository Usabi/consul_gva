require "rails_helper"
require "csv"

describe "Admin Valuators CSV" do
  let(:admin) { create(:administrator) }

  before { sign_in admin.user }
  describe "GET /admin/valuators.csv" do
    it "returns CSV with all valuators" do
      create_list(:valuator, 3)

      get admin_valuators_path(format: :csv)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
      expect(response.headers["Content-Disposition"]).to include("valuators.csv")
    end

    it "includes valuator group in CSV" do
      valuator_group = create(:valuator_group, name: "Health Group")
      valuator = create(:valuator, valuator_group: valuator_group)

      get admin_valuators_path(format: :csv)

      csv = CSV.parse(response.body, headers: true)
      group_column = I18n.t("admin.valuators.index.group")
      valuator_row = csv.find { |row| row["ID"] == valuator.id.to_s }

      expect(valuator_row[group_column]).to eq("Health Group")
    end
  end

  describe "GET /admin/valuators/search.csv" do
    it "returns CSV with search results" do
      user = create(:user, username: "searchable_valuator")
      create(:valuator, user: user)

      get search_admin_valuators_path(format: :csv, search: "searchable")

      expect(response).to have_http_status(:ok)
      csv = CSV.parse(response.body, headers: true)
      name_column = I18n.t("admin.valuators.index.name")

      expect(csv.count).to eq(1)
      expect(csv.first[name_column]).to eq("searchable_valuator")
    end
  end
end
