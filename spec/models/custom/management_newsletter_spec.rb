require "rails_helper"

RSpec.describe ManagementNewsletter do
  describe "validations" do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(described_class::STATUSES) }
  end

  describe "associations" do
    it { is_expected.to have_many(:management_newsletter_proposals).dependent(:destroy) }

    it {
      is_expected.to have_many(:most_supported_proposals).through(:management_newsletter_proposals)
                                                         .source(:proposal)
    }

    it { is_expected.to have_many(:management_newsletter_debates).dependent(:destroy) }
    it { is_expected.to have_many(:active_debates).through(:management_newsletter_debates).source(:debate) }
    it { is_expected.to have_many(:management_newsletter_preview_processes).dependent(:destroy) }

    it {
      is_expected.to have_many(:preview_processes).through(:management_newsletter_preview_processes)
                                                  .source(:process)
    }

    it { is_expected.to have_many(:management_newsletter_public_processes).dependent(:destroy) }

    it {
      is_expected.to have_many(:public_processes).through(:management_newsletter_public_processes)
                                                 .source(:process)
    }
  end

  describe ".newest_first" do
    let(:older) { create(:management_newsletter, created_at: 1.day.ago) }
    let!(:newer) { create(:management_newsletter, created_at: 1.hour.ago) }

    it "orders newsletters by created_at desc" do
      expect(ManagementNewsletter.newest_first.first).to eq(newer)
    end
  end

  describe "#status helpers" do
    subject { ManagementNewsletter.new(status: status) }

    context "pending" do
      let(:status) { "pending" }
      it { is_expected.to be_pending }
    end

    context "sent" do
      let(:status) { "sent" }
      it { is_expected.to be_sent }
    end

    context "failed" do
      let(:status) { "failed" }
      it { is_expected.to be_failed }
    end
  end

  describe "#status_class" do
    it "returns warning for pending" do
      expect(ManagementNewsletter.new(status: "pending").status_class).to eq("warning")
    end

    it "returns success for sent" do
      expect(ManagementNewsletter.new(status: "sent").status_class).to eq("success")
    end

    it "returns alert for failed" do
      expect(ManagementNewsletter.new(status: "failed").status_class).to eq("alert")
    end
  end

  describe "#mark_as_sent" do
    let(:newsletter) { create(:management_newsletter, status: "pending") }

    it "updates status and sent_at" do
      expect { newsletter.mark_as_sent }
        .to change(newsletter, :status).to("sent")
        .and change(newsletter, :sent_at)
    end
  end

  describe "#mark_as_failed" do
    let(:newsletter) { create(:management_newsletter, status: "pending") }

    it "updates status to failed" do
      expect { newsletter.mark_as_failed }
        .to change(newsletter, :status).to("failed")
    end
  end
end

RSpec.describe ManagementNewsletterProposal do
  it { is_expected.to belong_to(:management_newsletter) }
  it { is_expected.to belong_to(:proposal) }
end

RSpec.describe ManagementNewsletterDebate do
  it { is_expected.to belong_to(:management_newsletter) }
  it { is_expected.to belong_to(:debate) }
end

RSpec.describe ManagementNewsletterPreviewProcess do
  it { is_expected.to belong_to(:management_newsletter) }
  it { is_expected.to belong_to(:process).class_name("Legislation::Process") }
end

RSpec.describe ManagementNewsletterPublicProcess do
  it { is_expected.to belong_to(:management_newsletter) }
  it { is_expected.to belong_to(:process).class_name("Legislation::Process") }
end
