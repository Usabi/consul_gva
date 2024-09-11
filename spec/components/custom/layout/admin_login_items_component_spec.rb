require "rails_helper"

describe Layout::AdminLoginItemsComponent do
  it "shows the valuation link and admin budget to budget manager" do
    user = create(:budget_manager).user

    render_inline Layout::AdminLoginItemsComponent.new(user)

    expect(page).to have_link "Menu"

    page.find("ul") do |menu|
      expect(menu).to have_link "Valuation"
      expect(menu).to have_link "Participatory budgeting"
      expect(menu).to have_link count: 2
    end
  end

  it "shows the admin legislation processes content link to Legislators" do
    user = create(:legislator).user

    render_inline Layout::AdminLoginItemsComponent.new(user)

    expect(page).to have_link "Menu"

    page.find("ul") do |menu|
      expect(menu).to have_link "Collaborative legislation"
      expect(menu).to have_link count: 1
    end
  end

  it "shows several links to users with legislator and budget manager role" do
    user = create(:user)
    create(:budget_manager, user: user)
    create(:legislator, user: user)

    render_inline Layout::AdminLoginItemsComponent.new(user)

    expect(page).to have_link "Menu"

    page.find("ul") do |menu|
      expect(menu).to have_link "Valuation"
      expect(menu).to have_link "Participatory budgeting"
      expect(menu).to have_link "Collaborative legislation"
      expect(menu).to have_link count: 3
    end
  end
end
