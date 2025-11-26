require "rails_helper"

describe "Direct messages" do
  before do
    Setting[:direct_message_max_per_day] = 3
  end

  context "Administrator permissions" do
    scenario "Administrator can send private messages without verification" do
      admin = create(:administrator).user
      receiver = create(:user, :level_two)

      login_as(admin)
      visit user_path(receiver)

      click_link "Send private message"

      expect(page).to have_content "Send private message to #{receiver.name}"
      expect(page).not_to have_content "To send a private message verify your account"

      fill_in "direct_message_title", with: "Admin message"
      fill_in "direct_message_body",  with: "Message from administrator"
      click_button "Send message"

      expect(page).to have_content "You message has been sent successfully."
      expect(page).to have_content "Admin message"
      expect(page).to have_content "Message from administrator"
    end

    scenario "Administrator without verification can access direct message form" do
      admin = create(:administrator).user
      receiver = create(:user, :level_two)

      expect(admin.level_two_or_three_verified?).to be false

      login_as(admin)
      visit new_user_direct_message_path(receiver)

      expect(page).to have_content "Send private message to #{receiver.name}"
      expect(page).not_to have_content "To send a private message verify your account"
      expect(page).to have_current_path new_user_direct_message_path(receiver)
    end
  end

  context "Legislator permissions" do
    scenario "Legislator can send private messages without verification" do
      legislator_user = create(:user)
      create(:legislator, user: legislator_user)
      receiver = create(:user, :level_two)

      login_as(legislator_user)
      visit user_path(receiver)

      click_link "Send private message"

      expect(page).to have_content "Send private message to #{receiver.name}"
      expect(page).not_to have_content "To send a private message verify your account"

      fill_in "direct_message_title", with: "Legislator message"
      fill_in "direct_message_body",  with: "Message from legislator"
      click_button "Send message"

      expect(page).to have_content "You message has been sent successfully."
      expect(page).to have_content "Legislator message"
      expect(page).to have_content "Message from legislator"
    end

    scenario "Legislator without verification can access direct message form" do
      legislator_user = create(:user)
      create(:legislator, user: legislator_user)
      receiver = create(:user, :level_two)

      expect(legislator_user.level_two_or_three_verified?).to be false

      login_as(legislator_user)
      visit new_user_direct_message_path(receiver)

      expect(page).to have_content "Send private message to #{receiver.name}"
      expect(page).not_to have_content "To send a private message verify your account"
      expect(page).to have_current_path new_user_direct_message_path(receiver)
    end
  end

  context "Regular user verification requirement" do
    scenario "Unverified regular user still cannot send messages" do
      sender = create(:user)
      receiver = create(:user, :level_two)

      expect(sender.level_two_or_three_verified?).to be false

      login_as(sender)
      visit new_user_direct_message_path(receiver)

      expect(page).to have_content "To send a private message verify your account"
      expect(page).to have_current_path root_path
    end
  end
end
