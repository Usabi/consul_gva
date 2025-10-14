namespace :management_newsletters do
  desc "Generate and send daily/weekly management newsletter"
  task generate: :environment do
    frequency = Setting["management_newsletter_frequency"].presence || "weekly"

    if frequency == "weekly" && Time.zone.today.wday != 1
      Rails.logger.info "Skipping management newsletter generation
        because frequency is weekly and today is not Monday"
      next
    end

    most_supported_proposals = Proposal.sort_by_confidence_score.limit(3)
    active_debates = Debate.sort_by_supports.limit(3)
    preview_processes = Legislation::Process.published.active.preview_phase.order(start_date: :asc).limit(3)
    public_processes = Legislation::Process.published.active.public_phase.order(start_date: :asc).limit(3)

    if most_supported_proposals.empty? && active_debates.empty? &&
       preview_processes.empty? && public_processes.empty?
      Rails.logger.info "Skipping newsletter generation: no most_supported_proposals,
        active_debates, preview_processes or public_processes found"
      next
    end

    newsletter = ManagementNewsletter.create!(status: "pending")

    if most_supported_proposals.any?
      most_supported_proposals.each do |proposal|
        newsletter.management_newsletter_proposals.create!(proposal: proposal)
      end
    end

    if active_debates.any?
      active_debates.each do |debate|
        newsletter.management_newsletter_debates.create!(debate: debate)
      end
    end

    if preview_processes.any?
      preview_processes.each do |preview_process|
        newsletter.management_newsletter_preview_processes.create!(process: preview_process)
      end
    end

    if public_processes.any?
      public_processes.each do |public_process|
        newsletter.management_newsletter_public_processes.create!(process: public_process)
      end
    end

    begin
      newsletter.deliver
      newsletter.mark_as_sent
    rescue StandardError => e
      Rails.logger.error "Failed to send management newsletter: #{e.message}"
      newsletter.mark_as_failed
      raise e
    end
  end
end
