class Widget::Feeds::ParticipationComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "widget", "feeds", "participation_component.rb")

class Widget::Feeds::ParticipationComponent
  attr_reader :feeds

  def initialize(feeds)
    @feeds = feeds
  end

  private

    def feed_debates?(feed)
      feed.kind == "debates"
    end

    def feed_processes?(feed)
      feed.kind == "processes"
    end
end
