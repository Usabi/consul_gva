namespace :web_sections do
  desc "Update web sections"
  task update: :environment do
    ApplicationLogger.new.info "Loading seed db/web_sections.rb"
    load Rails.root.join("db", "web_sections.rb")
    ApplicationLogger.new.info "Seed db/web_sections.rb loaded"
  end
end
