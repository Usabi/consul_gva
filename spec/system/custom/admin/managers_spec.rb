require "rails_helper"

describe "Admin managers", :admin do
  context "Custom Search" do
    let(:user)      { create(:user, username: "Taylor Swift", email: "taylor@swift.com") }
    let(:user2)     { create(:user, username: "Stephanie Corneliussen", email: "steph@mrrobot.com") }
    let!(:manager1) { create(:manager, user: user) }
    let!(:manager2) { create(:manager, user: user2) }

    before do
      visit admin_managers_path
    end

    scenario "Delete after searching" do
      fill_in "search", with: manager2.email
      click_button "Search"

      accept_confirm("Are you sure? This action will delete \"#{manager2.name}\" and can't be undone.") do
        click_button "Delete"
      end

      expect(page).to have_content(manager1.email)
      expect(page).not_to have_content(manager2.email)
    end
  end
end
