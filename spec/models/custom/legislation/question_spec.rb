require "rails_helper"

describe Legislation::Question do
  describe "#first_question_id" do
    it "returns the first question including the default question created by after_create" do
      # Create a legislation process which triggers after_create callback
      process = create(:legislation_process)

      # Verify the default question was created by after_create
      expect(process.questions.count).to eq(1)
      default_question = process.questions.first

      # Create two additional questions
      question1 = create(:legislation_question, process: process)
      question2 = create(:legislation_question, process: process)

      # Now we should have 3 questions total (1 default + 2 created)
      expect(process.questions.count).to eq(3)

      # first_question_id should return the ID of the first question (the default one)
      expect(default_question.first_question_id).to eq(default_question.id)
      expect(question1.first_question_id).to eq(default_question.id)
      expect(question2.first_question_id).to eq(default_question.id)
    end
  end
end
