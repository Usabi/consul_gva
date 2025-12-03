require "rails_helper"
require "csv"

describe "Admin SDG Managers CSV" do
  let(:admin) { create(:administrator) }

  before { sign_in admin.user }

  describe "GET /admin/sdg/managers.csv" do
    it "returns CSV with all SDG managers" do
      create_list(:sdg_manager, 3)

      get admin_sdg_managers_path(format: :csv)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
      expect(response.headers["Content-Disposition"]).to include("sdg_managers.csv")
    end

    it "includes SDG manager data in CSV" do
      user = create(:user, username: "sdg_manager_user", email: "sdg@example.com")
      sdg_manager = create(:sdg_manager, user: user)

      get admin_sdg_managers_path(format: :csv)

      csv = CSV.parse(response.body, headers: true)
      id_column = I18n.t("activerecord.attributes.sdg/manager.id")
      username_column = I18n.t("activerecord.attributes.user.username")
      email_column = I18n.t("activerecord.attributes.user.email")

      sdg_manager_row = csv.find { |row| row[id_column] == sdg_manager.id.to_s }

      expect(sdg_manager_row[username_column]).to eq("sdg_manager_user")
      expect(sdg_manager_row[email_column]).to eq("sdg@example.com")
    end
  end
end
