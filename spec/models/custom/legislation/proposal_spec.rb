require "rails_helper"

describe Legislation::Proposal do
  let(:proposal) { create(:legislation_proposal) }

  describe "#editable?" do
    it "is true when the proposal has no supports" do
      expect(proposal).to be_editable
    end

    it "is false as soon as the proposal has one support" do
      create(:vote, votable: proposal)

      expect(proposal.reload).not_to be_editable
    end

    it "is false when the proposals phase has ended" do
      proposal.process.update!(proposals_phase_end_date: Date.yesterday)

      expect(proposal.reload).not_to be_editable
    end

    it "is false when the proposals phase has not started yet" do
      proposal.process.update!(proposals_phase_start_date: Date.tomorrow,
                               proposals_phase_end_date: Date.tomorrow + 2.days)

      expect(proposal.reload).not_to be_editable
    end

    it "is false when the process has ended even if the phase dates are still open" do
      proposal.process.update_columns(end_date: Date.yesterday)

      expect(proposal.reload).not_to be_editable
    end

    it "is false when the proposals phase is disabled" do
      proposal.process.update!(proposals_phase_enabled: false)

      expect(proposal.reload).not_to be_editable
    end
  end

  describe "#editable_by?" do
    it "is true for the author while there are no supports" do
      expect(proposal.editable_by?(proposal.author)).to be true
    end

    it "is false for other users" do
      expect(proposal.editable_by?(create(:user))).to be false
    end

    it "is false for the author once the proposal has supports" do
      create(:vote, votable: proposal)

      expect(proposal.reload.editable_by?(proposal.author)).to be false
    end
  end
end
