require "rails_helper"

describe "Legislation" do
  scenario "empty phases with default question" do
    # In custom, a default question is created automatically when a process is created
    process = create(:legislation_process, end_date: Date.current - 1.day)
    visit summary_legislation_process_path(process)

    expect(page).to have_content "Debate phase"
    expect(page).to have_content "1 debate"
    expect(page).to have_content I18n.t("admin.legislation.processes.default_question_title")

    expect(page).to have_content "Proposals phase"
    expect(page).to have_content "No proposals"
    expect(page).to have_content "There are no proposals"

    expect(page).to have_content "Comments phase"
    expect(page).to have_content "No comments"
    expect(page).to have_content "There are no comments"
  end
end
