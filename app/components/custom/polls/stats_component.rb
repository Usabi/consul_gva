class Polls::StatsComponent < ApplicationComponent
  def initialize(summary: false)
    @summary = summary
    @total_polls = Poll.count
    @polls_last_week = Poll.last_week.count
    @active_polls = Poll.current.count
    @expired_polls = Poll.expired.count
    @total_votes = Poll::Voter.count
    @votes_web = Poll::Voter.where(origin: "web").count
    @votes_booth = Poll::Voter.where(origin: "booth").count

    participants = Poll::Voter.select(:gender).distinct
    @total_participants = participants.count
    @total_male_participants = participants.where(gender: "male").count
    @total_female_participants = participants.where(gender: "female").count
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
