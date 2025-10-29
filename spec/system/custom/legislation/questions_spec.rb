require "rails_helper"

describe "Legislation" do
  context "process debate page" do
    let(:process) do
      create(:legislation_process,
             debate_start_date: Date.current - 3.days,
             debate_end_date: Date.current + 2.days)
    end

    before do
      create(:legislation_question, process: process, title: "Question 1", description: "Description 1")
      create(:legislation_question, process: process, title: "Question 2", description: "Description 2")
      create(:legislation_question, process: process, title: "Question 3", description: "Description 3")
    end

    scenario "shows default question page created automatically" do
      # The custom behavior creates a default question automatically
      default_question = process.questions.find_by(title: I18n.t("admin.legislation.processes.default_question_title"))

      expect(default_question).to be_present

      visit legislation_process_question_path(process, default_question)

      expect(page).to have_content(I18n.t("admin.legislation.processes.default_question_title"))
      expect(page).to have_content("Open answers (0)")
    end

    scenario "shows question page for manually created questions" do
      question = process.questions.find_by(title: "Question 1")
      visit legislation_process_question_path(process, question)

      expect(page).to have_content("Question 1")
      expect(page).to have_content("Description 1")
      expect(page).to have_content("Open answers (0)")
    end

    scenario "shows next question link in question page" do
      question1 = process.questions.find_by(title: "Question 1")
      visit legislation_process_question_path(process, question1)

      expect(page).to have_content("Question 1")
      expect(page).to have_content("Description 1")
      expect(page).to have_content("NEXT QUESTION")

      click_link "Next question"

      expect(page).to have_content("Question 2")
      expect(page).to have_content("Description 2")
      expect(page).to have_content("NEXT QUESTION")

      click_link "Next question"

      expect(page).to have_content("Question 3")
      expect(page).to have_content("Description 3")
      expect(page).not_to have_content("NEXT QUESTION")
    end
  end
end
