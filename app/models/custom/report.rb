load Rails.root.join("app", "models", "report.rb")

class Report < ApplicationRecord
  KINDS = %i[results stats advanced_stats status_executions].freeze
end
