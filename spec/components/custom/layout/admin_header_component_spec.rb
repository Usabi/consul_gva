require "rails_helper"

describe Layout::AdminHeaderComponent do
  let(:user) { create(:user) }
  before { Setting["org_name"] = "CONSUL" }

  around do |example|
    with_request_url("/") { example.run }
  end

  context "management section", controller: Management::BaseController do
    it "shows the menu button and menu for administrators" do
      create(:administrator, user: user)

      render_inline Layout::AdminHeaderComponent.new(user)

      expect(page).to have_css ".float-right"
    end

    it "does not show the menu button and menu for managers" do
      create(:manager, user: user)

      render_inline Layout::AdminHeaderComponent.new(user)

      expect(page).to have_css ".float-right"
    end
  end
end
