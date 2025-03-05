require "rails_helper"

describe "Admin alert messages magement", :admin do
  context "Index" do
    before do
      create(:alert_message, title: "Alert message number one",
                             description: "This is the text of alert_message number one and is not active yet",
                             target_url: "http://www.url.com",
                             active: false)

      create(:alert_message, title: "Alert message number two",
                             description: "This is the text of alert_message number two and is not longer active",
                             target_url: "http://www.url.com",
                             active: false)

      create(:alert_message, title: "Alert message number three",
                             description: "This is the text of alert_message number three",
                             target_url: "http://www.url.com")

      create(:alert_message, title: "Alert message number four",
                             description: "This is the text of alert_message number four",
                             target_url: "http://www.url.com")

      create(:alert_message, title: "Alert message number five",
                             description: "This is the text of alert_message number five",
                             target_url: "http://www.url.com")
    end

    scenario "Index show active alert messages" do
      visit admin_alert_messages_path(filter: "with_active")
      expect(page).to have_content("There are 3 alert messages")
    end

    scenario "Index show inactive alert messages" do
      visit admin_alert_messages_path(filter: "with_inactive")
      expect(page).to have_content("There are 2 alert messages")
    end

    scenario "Index show all alert messages" do
      visit admin_alert_messages_path
      expect(page).to have_content("There are 5 alert messages")
    end
  end

  scenario "Publish an alert message" do
    visit admin_root_path

    within("#side_menu") do
      click_link "Site content"
      click_link "Manage alert messages"
    end

    click_link "Create alert message"

    fill_in "Title", with: "Such alert message"
    fill_in "Description", with: "many text wow link"
    fill_in "Link", with: "https://www.url.com"
    within_fieldset("Sections where it will appear") { check "Proposals" }

    click_button "Save changes"

    expect(page).to have_content "Alert message created successfully"

    visit proposals_path

    expect(page).to have_content "Such alert message"
    expect(page).to have_link "Such alert message many text wow link", href: "https://www.url.com"
  end

  scenario "Publish an alert message with a translation different than the current locale" do
    visit new_admin_alert_message_path

    expect_to_have_language_selected "English"

    click_link "Remove language"
    select "Français", from: "add_language"

    fill_in "Title", with: "En Français"
    fill_in "Description", with: "Link en Français"
    fill_in "Link", with: "https://www.url.com"

    click_button "Save changes"
    click_link "Edit"

    expect_to_have_language_selected "Français"
    expect(page).to have_field "Title", with: "En Français"
  end

  scenario "Update alert message style" do
    visit new_admin_alert_message_path

    fill_in "Title", with: "Fun with flags"
    fill_in "Description", with: "Funny description"
    within_fieldset("Sections where it will appear") { check "Proposals" }
    select "Error", from: "alert_message[flash_key]"

    click_button "Save changes"

    expect(page).to have_content "Alert message created successfully"

    visit proposals_path

    expect(page).to have_css "#alert", text: "Fun with flags"
  end

  scenario "Delete an alert message" do
    create(:alert_message, title: "Ugly alert message",
                           description: "Bad text",
                           target_url: "http://www.url.com")

    visit admin_alert_messages_path

    expect(page).to have_content "Ugly alert message"

    accept_confirm("Are you sure? This action will delete \"Ugly alert message\" and can't be undone.") do
      click_button "Delete"
    end

    expect(page).to have_content "Alert message deleted successfully"

    visit admin_root_path
    expect(page).not_to have_content "Ugly alert message"
  end
end
