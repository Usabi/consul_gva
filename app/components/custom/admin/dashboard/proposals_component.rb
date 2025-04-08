class Admin::Dashboard::ProposalsComponent < ApplicationComponent
  def initialize(proposals:)
    @proposals = proposals
  end

  private

    def most_supported_proposals
      @proposals.sort_by_confidence_score.limit(5)
    end

    def near_threshold_proposals
      votes_needed = Proposal.votes_needed_for_success
      @proposals
        .where("cached_votes_up > ?", votes_needed * 0.8)
        .where("cached_votes_up < ?", votes_needed)
        .order(cached_votes_up: :desc)
        .limit(5)
    end
end
