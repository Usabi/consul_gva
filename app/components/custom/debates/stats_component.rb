class Debates::StatsComponent < ApplicationComponent
  def initialize(summary: false)
    @summary = summary
    @total_debates = Debate.count
    @debates_last_week = Debate.last_week.count
    @total_comments = Comment.where(commentable_type: "Debate").count
    @total_votes = Vote.where(votable_type: "Debate").count

    participants = User.distinct
                       .left_joins(:debates)
                       .left_joins(:comments)
                       .where("debates.author_id IS NOT NULL OR comments.commentable_type = ?", "Debate")
    @total_participants = participants.count
    @total_male_participants = participants.select { |r| r["gender"] == "male" }.count
    @total_female_participants = participants.select { |r| r["gender"] == "female" }.count
    @total_other_participants = @total_participants - @total_male_participants - @total_female_participants
    @male_percentage = percentage(@total_male_participants, @total_participants)
    @female_percentage = percentage(@total_female_participants, @total_participants)
    @other_percentage = percentage(@total_other_participants, @total_participants)
  end

  private

    def summary?
      @summary
    end

    def percentage(value, total)
      return 0 if total.zero?

      ((value.to_f / total) * 100).round(1)
    end
end
