class Widget::Feeds::ProposalParticipationComponent < ApplicationComponent
  attr_reader :feeds

  def initialize(feeds)
    @feeds = feeds
  end

  private

    def feed_proposals?(feed)
      feed.kind == "proposals"
    end

    def feed_selected_proposals?(feed)
      feed.kind == "selected_proposals"
    end
end
