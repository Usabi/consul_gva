require "rails_helper"

describe "citizen_newsletters tasks" do
  describe "rake citizen_newsletters:generate" do
    before do
      Rake::Task["citizen_newsletters:generate"].reenable
    end

    context "when today is not Monday" do
      before do
        # Set to Tuesday
        travel_to Date.new(2025, 11, 4) # November 4, 2025 is a Tuesday
      end

      it "skips newsletter generation" do
        expect do
          Rake.application.invoke_task("citizen_newsletters:generate")
        end.not_to change { CitizenNewsletter.count }
      end
    end

    context "when today is Monday" do
      before do
        # Set to Monday
        travel_to Date.new(2025, 11, 3) # November 3, 2025 is a Monday
      end

      context "with no content available" do
        it "skips newsletter generation when no content exists" do
          expect do
            Rake.application.invoke_task("citizen_newsletters:generate")
          end.not_to change { CitizenNewsletter.count }
        end
      end

      context "with content available" do
        before do
          create_list(:proposal, 3)
          create_list(:debate, 3)
          create(:legislation_process, :in_debate_phase, :published)
          create(:legislation_process, :published,
                 allegations_phase_enabled: true,
                 allegations_start_date: Date.current - 1.day,
                 allegations_end_date: Date.current + 5.days)
          create(:user, newsletter: true, newsletter_proposals: true,
                        newsletter_debates: true, newsletter_legislation: true)
        end

        it "creates a newsletter with content" do
          expect do
            Rake.application.invoke_task("citizen_newsletters:generate")
          end.to change { CitizenNewsletter.count }.by(1)

          newsletter = CitizenNewsletter.last
          expect(newsletter.most_supported_proposals.count).to be > 0
          expect(newsletter.active_debates.count).to be > 0
          expect(newsletter.preview_processes.count).to be > 0
          expect(newsletter.public_processes.count).to be > 0
        end

        it "delivers the newsletter and marks it as sent" do
          Rake.application.invoke_task("citizen_newsletters:generate")

          newsletter = CitizenNewsletter.last
          expect(newsletter.status).to eq("sent")
          expect(newsletter.sent_at).not_to be nil
        end

        it "sends emails to subscribed users" do
          expect_any_instance_of(CitizenNewsletter).to receive(:deliver).and_call_original
          Rake.application.invoke_task("citizen_newsletters:generate")
        end
      end

      context "when delivery fails" do
        it "marks newsletter as failed on error" do
          create(:proposal)
          create(:user, newsletter: true, newsletter_proposals: true)
          allow_any_instance_of(CitizenNewsletter).to receive(:deliver)
                                                  .and_raise(StandardError.new("Test error"))

          expect do
            Rake.application.invoke_task("citizen_newsletters:generate")
          end.to raise_error(StandardError, "Test error")

          newsletter = CitizenNewsletter.last
          expect(newsletter.status).to eq("failed")
        end
      end
    end
  end
end
