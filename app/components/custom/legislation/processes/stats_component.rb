class Legislation::Processes::StatsComponent < ApplicationComponent
  def initialize(summary: false)
    @summary = summary
    @total_processes = Legislation::Process.count
    @processes_last_week = Legislation::Process.last_week.count
    @active_processes = Legislation::Process.active.count
    @past_processes = Legislation::Process.past.count

    @preview_phase_count = Legislation::Process.preview_phase.count
    @public_phase_count = Legislation::Process.public_phase.count

    @total_proposals = Legislation::Proposal.count
    @proposals_last_week = Legislation::Proposal.last_week.count

    @total_votes = Vote.where(votable_type: Legislation::Process.name).count
    @total_comments = Comment.where(commentable_type: Legislation::Process.name).count

    @most_active_process = find_most_active_process

    participants = User.distinct
                       .left_joins(:legislation_answers)
                       .left_joins(:legislation_proposals)
                       .where("legislation_answers.user_id IS NOT NULL OR legislation_proposals.author_id IS NOT NULL")
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

    def find_most_active_process
      Legislation::Process
        .select("legislation_processes.*, COUNT(comments.id) as comment_count")
        .joins("LEFT JOIN comments ON comments.commentable_type = 'Legislation::Process'
                AND comments.commentable_id = legislation_processes.id")
        .group("legislation_processes.id")
        .order("comment_count DESC")
        .first
    end

    def percentage(value, total)
      return 0 if total.zero?

      ((value.to_f / total) * 100).round(1)
    end
end
