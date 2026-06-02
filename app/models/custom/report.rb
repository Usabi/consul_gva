load Rails.root.join("app", "models", "report.rb")

class Report < ApplicationRecord
  remove_const :KINDS
  KINDS = %i[results stats advanced_stats status_executions].freeze
end
