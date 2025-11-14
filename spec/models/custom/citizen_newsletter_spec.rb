require "rails_helper"

RSpec.describe CitizenNewsletter do
  describe "validations" do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(described_class::STATUSES) }
  end

  describe "associations" do
    it { is_expected.to have_many(:citizen_newsletter_proposals).dependent(:destroy) }

    it {
      is_expected.to have_many(:most_supported_proposals).through(:citizen_newsletter_proposals)
                                                         .source(:proposal)
    }

    it { is_expected.to have_many(:citizen_newsletter_debates).dependent(:destroy) }
    it { is_expected.to have_many(:active_debates).through(:citizen_newsletter_debates).source(:debate) }
    it { is_expected.to have_many(:citizen_newsletter_preview_processes).dependent(:destroy) }

    it {
      is_expected.to have_many(:preview_processes).through(:citizen_newsletter_preview_processes)
                                                  .source(:process)
    }

    it { is_expected.to have_many(:citizen_newsletter_public_processes).dependent(:destroy) }

    it {
      is_expected.to have_many(:public_processes).through(:citizen_newsletter_public_processes)
                                                 .source(:process)
    }
  end

  describe ".newest_first" do
    let(:older) { create(:citizen_newsletter, created_at: 1.day.ago) }
    let!(:newer) { create(:citizen_newsletter, created_at: 1.hour.ago) }

    it "orders newsletters by created_at desc" do
      expect(CitizenNewsletter.newest_first.first).to eq(newer)
    end
  end

  describe "#status helpers" do
    subject { CitizenNewsletter.new(status: status) }

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
      expect(CitizenNewsletter.new(status: "pending").status_class).to eq("warning")
    end

    it "returns success for sent" do
      expect(CitizenNewsletter.new(status: "sent").status_class).to eq("success")
    end

    it "returns alert for failed" do
      expect(CitizenNewsletter.new(status: "failed").status_class).to eq("alert")
    end
  end

  describe "#mark_as_sent" do
    let(:newsletter) { create(:citizen_newsletter, status: "pending") }

    it "updates status and sent_at" do
      expect { newsletter.mark_as_sent }
        .to change(newsletter, :status).to("sent")
        .and change(newsletter, :sent_at)
    end
  end

  describe "#mark_as_failed" do
    let(:newsletter) { create(:citizen_newsletter, status: "pending") }

    it "updates status to failed" do
      expect { newsletter.mark_as_failed }
        .to change(newsletter, :status).to("failed")
    end
  end

  describe "#deliver" do
    let(:newsletter) { create(:citizen_newsletter) }
    let!(:proposal) { create(:proposal) }
    let!(:debate) { create(:debate) }
    let!(:preview_process) { create(:legislation_process, :in_debate_phase, :published) }
    let!(:public_process) do
      create(:legislation_process, :published,
             allegations_phase_enabled: true,
             allegations_start_date: Date.current - 1.day,
             allegations_end_date: Date.current + 5.days)
    end

    before do
      newsletter.citizen_newsletter_proposals.create!(proposal: proposal)
      newsletter.citizen_newsletter_debates.create!(debate: debate)
      newsletter.citizen_newsletter_preview_processes.create!(process: preview_process)
      newsletter.citizen_newsletter_public_processes.create!(process: public_process)
    end

    context "with subscribers" do
      let!(:user_proposals) do
        create(:user, newsletter: true, newsletter_proposals: true,
                      newsletter_debates: false, newsletter_legislation: false)
      end
      let!(:user_debates) do
        create(:user, newsletter: true, newsletter_proposals: false,
                      newsletter_debates: true, newsletter_legislation: false)
      end
      let!(:user_legislation) do
        create(:user, newsletter: true, newsletter_proposals: false,
                      newsletter_debates: false, newsletter_legislation: true)
      end
      let!(:user_no_prefs) do
        create(:user, newsletter: true, newsletter_proposals: false,
                      newsletter_debates: false, newsletter_legislation: false)
      end

      it "sends emails to users with matching preferences" do
        expect(Mailer).to receive(:citizen_newsletter).with(newsletter,
                                                            user_proposals)
                                                      .and_return(double(deliver_later: true))
        expect(Mailer).to receive(:citizen_newsletter).with(newsletter,
                                                            user_debates)
                                                      .and_return(double(deliver_later: true))
        expect(Mailer).to receive(:citizen_newsletter).with(newsletter,
                                                            user_legislation)
                                                      .and_return(double(deliver_later: true))
        expect(Mailer).not_to receive(:citizen_newsletter).with(newsletter, user_no_prefs)

        newsletter.deliver
      end

      it "generates subscriptions_token for users" do
        allow(Mailer).to receive(:citizen_newsletter).and_return(double(deliver_later: true))

        expect { newsletter.deliver }
          .to change { user_proposals.reload.subscriptions_token }.from(nil)
      end
    end

    context "with no subscribers" do
      it "does not send any emails" do
        expect(Mailer).not_to receive(:citizen_newsletter)
        newsletter.deliver
      end
    end

    context "when not pending or failed" do
      let(:newsletter) { create(:citizen_newsletter, status: "sent") }

      it "does not send emails" do
        expect(Mailer).not_to receive(:citizen_newsletter)
        newsletter.deliver
      end
    end
  end
end

RSpec.describe CitizenNewsletterProposal do
  it { is_expected.to belong_to(:citizen_newsletter) }
  it { is_expected.to belong_to(:proposal) }
end

RSpec.describe CitizenNewsletterDebate do
  it { is_expected.to belong_to(:citizen_newsletter) }
  it { is_expected.to belong_to(:debate) }
end

RSpec.describe CitizenNewsletterPreviewProcess do
  it { is_expected.to belong_to(:citizen_newsletter) }
  it { is_expected.to belong_to(:process).class_name("Legislation::Process") }
end

RSpec.describe CitizenNewsletterPublicProcess do
  it { is_expected.to belong_to(:citizen_newsletter) }
  it { is_expected.to belong_to(:process).class_name("Legislation::Process") }
end
