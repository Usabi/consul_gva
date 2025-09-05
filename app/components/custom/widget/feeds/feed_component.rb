class Widget::Feeds::FeedComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "widget", "feeds", "feed_component.rb")

class Widget::Feeds::FeedComponent
  def selected_proposals_path
    proposals_path(selected: "all")
  end

  private

    def item_component_class
      case kind
      when "proposals"
        Widget::Feeds::ProposalComponent
      when "debates"
        Widget::Feeds::DebateComponent
      when "processes"
        Widget::Feeds::ProcessComponent
      when "selected_proposals"
        Widget::Feeds::SelectedProposalsComponent
      end
    end
end
