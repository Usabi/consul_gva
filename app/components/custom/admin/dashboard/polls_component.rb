class Admin::Dashboard::PollsComponent < ApplicationComponent
  def initialize(polls:)
    @polls = polls
  end

  private

    def active_polls
      @polls.current.order(ends_at: :asc).limit(5)
    end
end
