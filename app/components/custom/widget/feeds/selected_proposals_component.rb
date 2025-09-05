class Widget::Feeds::SelectedProposalsComponent < ApplicationComponent
  attr_reader :proposal

  def initialize(proposal)
    @proposal = proposal
  end
end
