require "rails_helper"

describe "Homepage", :admin do
  let(:user) { create(:user, :level_two) }

  scenario "Recommendations are not shown in custom" do
    create(:proposal, tag_list: "Sport", followers: [user])
    create(:proposal, tag_list: "Sport")

    login_as(user)
    visit root_path

    expect(page).not_to have_content("Recommendations that may interest you")
  end
end
