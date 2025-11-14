namespace :citizen_newsletters do
  desc "Generate and send weekly citizen newsletter"
  task :generate, [:force] => :environment do |_t, args|
    if args[:force] != "true" && Time.zone.today.wday != 1
      puts "Skipping citizen newsletter generation because today is not Monday"
      Rails.logger.info "Skipping citizen newsletter generation because today is not Monday"
      next
    end

    puts "Starting citizen newsletter generation..."
    most_supported_proposals = Proposal.sort_by_confidence_score.limit(3)
    active_debates = Debate.sort_by_supports.limit(3)
    preview_processes = Legislation::Process.published.active.preview_phase.order(start_date: :asc).limit(3)
    public_processes = Legislation::Process.published.active.public_phase.order(start_date: :asc).limit(3)

    puts "Found content: #{most_supported_proposals.count} proposals, " \
         "#{active_debates.count} debates, " \
         "#{preview_processes.count} preview processes, " \
         "#{public_processes.count} public processes"
    Rails.logger.info "Found content: #{most_supported_proposals.count} proposals, " \
                      "#{active_debates.count} debates, " \
                      "#{preview_processes.count} preview processes, " \
                      "#{public_processes.count} public processes"

    if most_supported_proposals.empty? && active_debates.empty? &&
       preview_processes.empty? && public_processes.empty?
      puts "Skipping citizen newsletter generation: no content found"
      Rails.logger.info "Skipping citizen newsletter generation: no content found"
      next
    end

    puts "Creating newsletter..."
    Rails.logger.info "Creating newsletter..."
    newsletter = CitizenNewsletter.create!(status: "pending")
    puts "Newsletter created with ID: #{newsletter.id}"
    Rails.logger.info "Newsletter created with ID: #{newsletter.id}"

    if most_supported_proposals.any?
      most_supported_proposals.each do |proposal|
        newsletter.citizen_newsletter_proposals.create!(proposal: proposal)
      end
    end

    if active_debates.any?
      active_debates.each do |debate|
        newsletter.citizen_newsletter_debates.create!(debate: debate)
      end
    end

    if preview_processes.any?
      preview_processes.each do |process|
        newsletter.citizen_newsletter_preview_processes.create!(process: process)
      end
    end

    if public_processes.any?
      public_processes.each do |process|
        newsletter.citizen_newsletter_public_processes.create!(process: process)
      end
    end

    begin
      newsletter.deliver
      newsletter.mark_as_sent
      Rails.logger.info "Citizen newsletter sent successfully"
    rescue StandardError => e
      Rails.logger.error "Failed to send citizen newsletter: #{e.message}"
      newsletter.mark_as_failed
      raise e
    end
  end
end
