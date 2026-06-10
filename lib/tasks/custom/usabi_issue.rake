namespace :usabi_issue do
  desc "Show issue"
  task number_issue: :environment do
    ApplicationLogger.new.info "#{USABI_ISSUE} - Ruby #{RUBY_VERSION}"
  end
end
