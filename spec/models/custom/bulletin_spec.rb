require "rails_helper"

describe Bulletin do
  describe "#citizen_newsletter_segment" do
    it "returns newsletter_proposals for proposal template" do
      bulletin = create(:bulletin, template: "proposal")
      expect(bulletin.citizen_newsletter_segment).to eq("newsletter_proposals")
    end

    it "returns newsletter_debates for debate template" do
      bulletin = create(:bulletin, template: "debate")
      expect(bulletin.citizen_newsletter_segment).to eq("newsletter_debates")
    end

    it "returns newsletter_legislation for legislation_process_preview_phase template" do
      bulletin = create(:bulletin, template: "legislation_process_preview_phase")
      expect(bulletin.citizen_newsletter_segment).to eq("newsletter_legislation")
    end

    it "returns newsletter_legislation for legislation_process_public_phase template" do
      bulletin = create(:bulletin, template: "legislation_process_public_phase")
      expect(bulletin.citizen_newsletter_segment).to eq("newsletter_legislation")
    end

    it "returns newsletter_legislation for legislation_process_past template" do
      bulletin = create(:bulletin, template: "legislation_process_past")
      expect(bulletin.citizen_newsletter_segment).to eq("newsletter_legislation")
    end

    it "returns newsletter_legislation for legislation_process_results template" do
      bulletin = create(:bulletin, template: "legislation_process_results")
      expect(bulletin.citizen_newsletter_segment).to eq("newsletter_legislation")
    end

    it "returns nil for unknown template" do
      bulletin = build(:bulletin, template: "unknown")
      expect(bulletin.citizen_newsletter_segment).to be nil
    end
  end

  describe "#for_citizen_newsletter?" do
    it "returns true when bulletin has a citizen newsletter segment" do
      bulletin = create(:bulletin, template: "proposal")
      expect(bulletin.for_citizen_newsletter?).to be true
    end

    it "returns false when bulletin has no citizen newsletter segment" do
      bulletin = build(:bulletin, template: "unknown")
      expect(bulletin.for_citizen_newsletter?).to be false
    end
  end
end
