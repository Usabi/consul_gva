require "rails_helper"

RSpec.describe "CitizenNewsletters" do
  let(:user) { create(:user) }

  before do
    Setting["feature.citizen_newsletter"] = true
  end

  scenario "guest user sees call to action on homepage" do
    visit root_path

    within "#citizen_newsletter_cta" do
      expect(page).to have_content(I18n.t("citizen_newsletter.call_to_action.title"))
      expect(page).to have_content(I18n.t("citizen_newsletter.call_to_action.description"))
      expect(page).to have_link(I18n.t("citizen_newsletter.call_to_action.guest"))
    end
  end

  scenario "signed in user sees call to action on homepage linking to account settings" do
    login_as user

    visit root_path

    within "#citizen_newsletter_cta" do
      expect(page).to have_content(I18n.t("citizen_newsletter.call_to_action.title"))
      expect(page).to have_link(I18n.t("citizen_newsletter.call_to_action.signed_in"))
    end
  end

  scenario "user manages newsletter preferences in account settings" do
    login_as user

    visit account_path

    expect(page).to have_css("h2#citizen_newsletter", text: I18n.t("account.show.citizen_newsletter.title"))
    expect(page).to have_content(I18n.t("account.show.citizen_newsletter.description"))

    check I18n.t("activerecord.attributes.user.newsletter_debates")
    check I18n.t("activerecord.attributes.user.newsletter_proposals")
    check I18n.t("activerecord.attributes.user.newsletter_legislation")

    click_button "Save changes"

    expect(page).to have_content("Changes saved")

    user.reload
    expect(user.newsletter_debates).to be true
    expect(user.newsletter_proposals).to be true
    expect(user.newsletter_legislation).to be true
  end

  scenario "user unsubscribes from citizen newsletters via email link", :js do
    user.update!(
      newsletter_debates: true,
      newsletter_proposals: true,
      newsletter_legislation: true
    )
    user.add_subscriptions_token

    visit citizen_newsletter_unsubscribe_path(token: user.subscriptions_token)

    expect(page).to have_content(I18n.t("citizen_newsletter.unsubscribe.title"))
    expect(page).to have_content(I18n.t("citizen_newsletter.unsubscribe.confirmation_question"))

    accept_confirm do
      click_button I18n.t("citizen_newsletter.unsubscribe.confirm_button")
    end

    expect(page).to have_content(I18n.t("citizen_newsletter.unsubscribe.success"))

    user.reload
    expect(user.newsletter_debates).to be false
    expect(user.newsletter_proposals).to be false
    expect(user.newsletter_legislation).to be false
  end

  scenario "user cancels unsubscription" do
    user.update!(
      newsletter_debates: true,
      newsletter_proposals: true,
      newsletter_legislation: true
    )
    user.add_subscriptions_token

    visit citizen_newsletter_unsubscribe_path(token: user.subscriptions_token)

    click_link I18n.t("citizen_newsletter.unsubscribe.cancel_button")

    expect(page).to have_current_path(root_path)

    user.reload
    expect(user.newsletter_debates).to be true
    expect(user.newsletter_proposals).to be true
    expect(user.newsletter_legislation).to be true
  end

  scenario "user tries to unsubscribe with invalid token" do
    visit citizen_newsletter_unsubscribe_path(token: "invalid_token")

    expect(page).to have_content(I18n.t("citizen_newsletter.unsubscribe.invalid_token"))
    expect(page).to have_current_path(root_path)
  end

  scenario "CTA is not shown when feature is disabled" do
    Setting["feature.citizen_newsletter"] = nil

    visit root_path

    expect(page).not_to have_css("#citizen_newsletter_cta")
  end
end
