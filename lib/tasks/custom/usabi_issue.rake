namespace :usabi_issue do
  desc "Show issue"
  task number_issue: :environment do
    ApplicationLogger.new.info "Issue 8365"
  end
end
