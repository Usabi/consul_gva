require "rails_helper"

describe "Admin Profiles Menu", :admin do
  scenario "Profiles menu stays open when navigating to Supporters" do
    visit admin_supporters_path

    expect(page).to have_current_path(admin_supporters_path)

    expect(page).to have_css('button.profiles-link[aria-expanded="true"]')

    profiles_button = page.find("button.profiles-link")
    profiles_menu = profiles_button.sibling("ul")

    within(profiles_menu) do
      expect(page).to have_css('li[aria-current="true"]', count: 1)

      supporters_item = page.find('li[aria-current="true"]')
      expect(supporters_item).to have_link("Supporters")
    end
  end

  scenario "Profiles menu stays open when navigating to Legislators" do
    visit admin_legislators_path

    expect(page).to have_current_path(admin_legislators_path)

    expect(page).to have_css('button.profiles-link[aria-expanded="true"]')

    profiles_button = page.find("button.profiles-link")
    profiles_menu = profiles_button.sibling("ul")

    within(profiles_menu) do
      expect(page).to have_css('li[aria-current="true"]', count: 1)

      legislators_item = page.find('li[aria-current="true"]')
      expect(legislators_item).to have_link("Legislators")
    end
  end

  scenario "Profiles menu stays open when navigating to Budget Managers" do
    visit admin_budget_managers_path

    expect(page).to have_current_path(admin_budget_managers_path)

    expect(page).to have_css('button.profiles-link[aria-expanded="true"]')

    profiles_button = page.find("button.profiles-link")
    profiles_menu = profiles_button.sibling("ul")

    within(profiles_menu) do
      expect(page).to have_css('li[aria-current="true"]', count: 1)

      budget_managers_item = page.find('li[aria-current="true"]')
      expect(budget_managers_item).to have_link("Budget participatory administrators")
    end
  end

  scenario "Profiles menu shows all profile sections as accessible" do
    profile_sections = [
      { name: "Administrators", path: admin_administrators_path },
      { name: "Supporters", path: admin_supporters_path },
      { name: "Organizations", path: admin_organizations_path },
      { name: "Officials", path: admin_officials_path },
      { name: "Moderators", path: admin_moderators_path },
      { name: "Valuators", path: admin_valuators_path },
      { name: "Managers", path: admin_managers_path },
      { name: "Legislators", path: admin_legislators_path },
      { name: "Budget participatory administrators", path: admin_budget_managers_path },
      { name: "Users", path: admin_users_path }
    ]

    profile_sections.each do |section|
      visit section[:path]

      expect(page).to have_current_path(section[:path])

      expect(page).to have_css(".profiles-link"),
                      "Expected profiles menu to exist when viewing #{section[:name]}"
    end
  end
end
