class Proposals::StatsComponent < ApplicationComponent
  def initialize(summary: false)
    @summary = summary
    @total_proposals = Proposal.count
    @proposals_last_week = Proposal.last_week.count
    @proposals_open = Proposal.not_archived.count
    @proposals_archived = Proposal.archived.count
    @total_votes = Vote.where(votable_type: "Proposal").count
    @total_comments = Comment.where(commentable_type: "Proposal").count

    participants = User.distinct
                       .left_joins(:proposals)
                       .left_joins(:comments)
                       .where("proposals.author_id IS NOT NULL OR (comments.user_id IS NOT NULL AND comments.commentable_type = ?)", "Proposal")
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
