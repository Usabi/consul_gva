require "rails_helper"

describe "Supporter admin access" do
  let(:supporter_user) { create(:supporter).user }

  before { login_as(supporter_user) }

  describe "Bug fix: legislation processes create button" do
    scenario "Supporter does not see the 'New process' button" do
      visit admin_legislation_processes_path

      expect(page).not_to have_link href: new_admin_legislation_process_path
    end

    scenario "Administrator sees the 'New process' button" do
      login_as(create(:administrator).user)
      visit admin_legislation_processes_path

      expect(page).to have_link href: new_admin_legislation_process_path
    end
  end

  describe "Bug fix: polls create and action buttons" do
    let!(:poll) { create(:poll, name: "Encuesta de prueba") }

    scenario "Supporter does not see the 'New poll' button" do
      visit admin_polls_path

      expect(page).not_to have_link href: new_admin_poll_path
    end

    scenario "Supporter does not see edit or delete buttons for polls" do
      visit admin_polls_path

      within "#poll_#{poll.id}" do
        expect(page).not_to have_link href: edit_admin_poll_path(poll)
        expect(page).not_to have_button I18n.t("admin.actions.delete")
      end
    end

    scenario "Administrator sees edit and delete buttons for polls" do
      login_as(create(:administrator).user)
      visit admin_polls_path

      within "#poll_#{poll.id}" do
        expect(page).to have_link href: edit_admin_poll_path(poll)
      end
    end
  end

  describe "Bug fix: budgets create button" do
    scenario "Supporter does not see the 'New budget' button" do
      visit admin_budgets_path

      expect(page).not_to have_button I18n.t("admin.budgets.index.new_link")
    end

    scenario "Administrator sees the 'New budget' button" do
      login_as(create(:administrator).user)
      visit admin_budgets_path

      expect(page).to have_button I18n.t("admin.budgets.index.new_link")
    end
  end

  describe "Bug fix: hidden content moderation pages" do
    scenario "Supporter is redirected from hidden proposals page" do
      visit admin_hidden_proposals_path

      expect(page).to have_current_path root_path
    end

    scenario "Supporter is redirected from hidden debates page" do
      visit admin_hidden_debates_path

      expect(page).to have_current_path root_path
    end

    scenario "Supporter is redirected from hidden comments page" do
      visit admin_hidden_comments_path

      expect(page).to have_current_path root_path
    end

    scenario "Supporter is redirected from hidden users page" do
      visit admin_hidden_users_path

      expect(page).to have_current_path root_path
    end

    scenario "Administrator can access hidden proposals page" do
      login_as(create(:administrator).user)
      visit admin_hidden_proposals_path

      expect(page).to have_current_path admin_hidden_proposals_path
    end
  end
end
