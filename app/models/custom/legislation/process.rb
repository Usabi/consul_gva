require_dependency Rails.root.join("app", "models", "legislation", "process").to_s

class Legislation::Process
  include Filterable

  belongs_to :user, optional: true, inverse_of: :legislation_processes

  def self.processes_filters
    %w[preview_phase public_phase past relevance]
  end

  scope :preview_phase, -> {
    where("(debate_phase_enabled = true and (debate_start_date <= :date and debate_end_date >= :date)) or
          (proposals_phase_enabled = true and (proposals_phase_start_date <= :date and proposals_phase_end_date >= :date))", date: Date.current)
  }
  scope :public_phase, -> { where("allegations_phase_enabled = true and (allegations_start_date <= :date and allegations_end_date >= :date)", date: Date.current) }

  def searchable_values
    {
      user.username => "B"
    }.merge!(searchable_globalized_values)
  end
end
