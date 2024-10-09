require_dependency Rails.root.join("app", "models", "report").to_s

class Report < ApplicationRecord
  KINDS = %i[results stats advanced_stats status_executions].freeze
end
