PgSearch.unaccent_function = (Rails.env.test? || Rails.env.development?) ? "unaccent" : Rails.application.secrets.unaccent_schema # rubocop:disable Layout/LineLength
