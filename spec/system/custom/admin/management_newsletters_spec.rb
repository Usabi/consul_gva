require "rails_helper"

RSpec.feature "Admin::ManagementNewsletters", type: :feature do
  let(:admin) { create(:administrator) }
  let!(:newsletter) { create(:management_newsletter, status: 'pending') }

  before { login_as admin.user }

  scenario "admin sees newsletters index" do
    visit admin_management_newsletters_path
    expect(page).to have_content(newsletter.status.upcase_first)
  end

  scenario "admin views a newsletter" do
    visit admin_management_newsletter_path(newsletter)
    expect(page).to have_content(newsletter.status.upcase_first)
  end

  scenario "admin resends a newsletter" do
    visit admin_management_newsletters_path
    click_link "Resend"
    expect(page).to have_content(I18n.t("admin.management_newsletters.resend.success"))
  end

  scenario "admin sees frequency configuration with default or set value" do
    Setting["management_newsletter_frequency"] = nil
    visit admin_management_newsletters_path
    expect(page).to have_checked_field("Weekly")

    choose("Daily")
    click_button I18n.t("admin.management_newsletters.configuration.save")
    expect(page).to have_content(I18n.t("admin.management_newsletters.configuration.updated"))
    expect(Setting["management_newsletter_frequency"]).to eq("daily")

    visit admin_management_newsletters_path
    expect(page).to have_checked_field("Daily")
  end
end
