class Debates::MarkFeaturedActionComponent < ApplicationComponent
  attr_reader :debate
  delegate :can?, to: :helpers

  def initialize(debate)
    @debate = debate
  end

  def render?
    can? :mark_featured, debate
  end
end
