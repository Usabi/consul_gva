require "rails_helper"

describe "Account" do
  let(:user) { create(:user, username: "Manuela Colau") }

  before do
    login_as(user)
  end

  describe "Email digest checkbox" do
    scenario "Does not appear when the proposals process is disabled" do
      Setting["process.proposals"] = false

      visit account_path

      expect(page).to have_field "Receive a summary of proposal notifications"
    end
  end
end
