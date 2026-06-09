require "rails_helper"

describe "Admin polls" do
  let(:admin) { create(:administrator).user }

  before do
    login_as(admin)
  end

  scenario "Index show polls list order by id desc (custom default order)" do
    poll_1 = create(:poll, name: "Poll first",  starts_at: 15.days.ago)
    poll_2 = create(:poll, name: "Poll second", starts_at: 1.month.ago)
    poll_3 = create(:poll, name: "Poll third",  starts_at: 2.days.ago)

    visit admin_root_path

    click_link "Polls"

    expect(page).to have_content "List of polls"
    expect(page).to have_css ".poll", count: 3

    # In custom, default order is by id:desc (most recent ID first)
    expect(poll_3.name).to appear_before(poll_2.name)
    expect(poll_2.name).to appear_before(poll_1.name)
    expect(page).not_to have_content "There are no polls"
  end

  context "Search and filter form" do
    scenario "Filters polls by status: current" do
      current_poll = create(:poll, name: "Encuesta activa")
      expired_poll = create(:poll, :expired, name: "Encuesta finalizada")

      visit admin_polls_path
      find("select[name='filter'] option[value='current']").select_option
      find("form[action='#{admin_polls_path}'] [type='submit']").click

      expect(page).to have_content current_poll.name
      expect(page).not_to have_content expired_poll.name
    end

    scenario "Filters polls by status: expired" do
      current_poll = create(:poll, name: "Encuesta activa")
      expired_poll = create(:poll, :expired, name: "Encuesta finalizada")

      visit admin_polls_path
      find("select[name='filter'] option[value='expired']").select_option
      find("form[action='#{admin_polls_path}'] [type='submit']").click

      expect(page).to have_content expired_poll.name
      expect(page).not_to have_content current_poll.name
    end

    scenario "Searches polls by name" do
      create(:poll, name: "Encuesta de movilidad")
      create(:poll, name: "Encuesta de reciclaje")

      visit admin_polls_path
      fill_in "name_or_id", with: "movilidad"
      find("form[action='#{admin_polls_path}'] [type='submit']").click

      expect(page).to have_content "Encuesta de movilidad"
      expect(page).not_to have_content "Encuesta de reciclaje"
    end
  end

  context "SDG related list" do
    scenario "show SDG filter dropdowns even when feature is disabled" do
      poll = create(:poll, name: "Poll with SDG related content")
      poll.sdg_goals = [SDG::Goal[1], SDG::Goal[17]]

      Setting["feature.sdg"] = false

      visit admin_polls_path

      # In custom, SDG filter dropdowns are always shown regardless of feature flag
      expect(page).to have_select "goal"
      expect(page).to have_select "target"
    end
  end

  context "Results" do
    context "Poll show" do
      scenario "Enable stats and results for booth polls" do
        unvoted_poll = create(:poll)

        voted_poll = create(:poll)
        create(:poll_voter, :from_booth, :valid_document, poll: voted_poll)

        visit admin_poll_results_path(unvoted_poll)

        expect(page).to have_content "There are no results"
        expect(page).not_to have_content "Display results and statistics"

        visit admin_poll_results_path(voted_poll)

        expect(page).to have_content "Display results and statistics"
        expect(page).not_to have_content "There are no results"
      end

      scenario "Enable stats and results for online polls" do
        unvoted_poll = create(:poll)

        voted_poll = create(:poll)
        create(:poll_voter, poll: voted_poll)

        visit admin_poll_results_path(unvoted_poll)

        expect(page).to have_content "There are no results"
        expect(page).not_to have_content "Display results and statistics"

        visit admin_poll_results_path(voted_poll)

        expect(page).to have_content "Display results and statistics"
        expect(page).not_to have_content "There are no results"
        expect(page).not_to have_content "Results by booth"
      end
    end
  end
end
