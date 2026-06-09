require "rails_helper"

describe Proposal do
  describe ".proposals_orders" do
    it "includes 'selected' order option" do
      user = create(:user)

      expect(Proposal.proposals_orders(user)).to include("selected")
    end
  end

  describe ".sort_by_selected" do
    it "returns only selected proposals" do
      selected_proposal = create(:proposal, :selected)
      create(:proposal)

      expect(Proposal.sort_by_selected).to match_array([selected_proposal])
    end
  end
end
