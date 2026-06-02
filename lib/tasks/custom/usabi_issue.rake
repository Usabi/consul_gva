namespace :usabi_issue do
  desc "Show issue"
  task number_issue: :environment do
    ApplicationLogger.new.info "Issue 7683 - 2.2.2 - 20260602154408"
  end
end
