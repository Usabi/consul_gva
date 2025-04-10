class Admin::Dashboard::DebatesComponent < ApplicationComponent
  def initialize(debates:)
    @debates = debates
  end

  private

    def most_voted_debates
      @debates.sort_by_hot_score.limit(5)
    end

    def most_commented_debates
      @debates.sort_by_most_commented.limit(5)
    end
end
