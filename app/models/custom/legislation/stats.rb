class Legislation::Stats
  attr_reader :total_participants, :total_male_participants, :total_female_participants,
              :total_other_participants, :male_percentage, :female_percentage, :other_percentage

  def initialize(process)
    question_ids = process.questions.pluck(:id)

    participants = User.distinct
                        .left_joins(:legislation_answers, :legislation_proposals)
                        .where(
                          "(legislation_answers.legislation_question_id IN (?) AND legislation_answers.user_id IS NOT NULL)
                           OR (legislation_proposals.legislation_process_id = ? AND legislation_proposals.author_id IS NOT NULL)",
                          question_ids, process.id
                        )

    @total_participants = participants.count
    @total_male_participants = participants.select { |user| user["gender"] == "male" }.count
    @total_female_participants = participants.select { |user| user["gender"] == "female" }.count
    @total_other_participants = @total_participants - @total_male_participants - @total_female_participants
    @male_percentage = percentage(@total_male_participants, @total_participants)
    @female_percentage = percentage(@total_female_participants, @total_participants)
    @other_percentage = percentage(@total_other_participants, @total_participants)
  end

  private

    def percentage(value, total)
      return 0 if total.zero?

      ((value.to_f / total) * 100).round(1)
    end
end
