namespace :unaccent do
  desc "Verify unaccent enable"
  task verify_unaccent: :environment do
    ApplicationLogger.new.info "Verify schema"
    ApplicationLogger.new.info ActiveRecord::Base.connection.execute("SHOW search_path;").values
    ApplicationLogger.new.info "Verify unaccent"
    result = ActiveRecord::Base.connection.execute("SELECT * FROM pg_extension WHERE extname = 'unaccent';")
    if result.ntuples == 1
      ApplicationLogger.new.info "Unaccent extension is enabled."
    else
      ApplicationLogger.new.info "Unaccent extension is NOT enabled."
    end
  end
end
