require "rails_helper"

describe "Admin supporters", :admin do
  let!(:user) { create(:user, username: "Jose Luis Balbin") }
  let!(:supporter) { create(:supporter, description: "Very reliable") }

  scenario "Index" do
    visit admin_supporters_path

    expect(page).to have_content(supporter.name)
    expect(page).to have_content(supporter.email)
    expect(page).not_to have_content(user.name)
  end

  scenario "Create" do
    visit admin_supporters_path

    fill_in "search", with: user.email
    click_button "Search"

    expect(page).to have_content(user.name)
    click_button "Add to supporters"

    within("#supporters") do
      expect(page).to have_content(user.name)
    end
  end


  scenario "Destroy" do
    visit admin_supporters_path

    accept_confirm("Are you sure? This action will delete \"#{supporter.name}\" and can't be undone.") do
      click_button "Delete"
    end

    within("#supporters") do
      expect(page).not_to have_content(supporter.name)
    end
  end

  context "Search" do
    let!(:user1) { create(:user, username: "David Foster Wallace", email: "david@wallace.com") }
    let!(:user2) { create(:user, username: "Steven Erikson", email: "steven@erikson.com") }
    let!(:supporter1) { create(:supporter, user: user1) }
    let!(:supporter2) { create(:supporter, user: user2) }

    before do
      visit admin_supporters_path
    end

    scenario "returns no results if search term is empty" do
      expect(page).to have_content(supporter1.name)
      expect(page).to have_content(supporter2.name)

      fill_in "search", with: " "
      click_button "Search"

      expect(page).to have_content("Supporters: User search")
      expect(page).to have_content("No results found")
      expect(page).not_to have_content(supporter1.name)
      expect(page).not_to have_content(supporter2.name)
    end

    scenario "search by name" do
      expect(page).to have_content(supporter1.name)
      expect(page).to have_content(supporter2.name)

      fill_in "search", with: "Foster"
      click_button "Search"

      expect(page).to have_content("Supporters: User search")
      expect(page).to have_field "search", with: "Foster"
      expect(page).to have_content(supporter1.name)
      expect(page).not_to have_content(supporter2.name)
    end

    scenario "search by email" do
      expect(page).to have_content(supporter1.email)
      expect(page).to have_content(supporter2.email)

      fill_in "search", with: supporter2.email
      click_button "Search"

      expect(page).to have_content("Supporters: User search")
      expect(page).to have_field "search", with: supporter2.email
      expect(page).to have_content(supporter2.email)
      expect(page).not_to have_content(supporter1.email)
    end
  end
end
