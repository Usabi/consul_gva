require_dependency Rails.root.join("app", "models", "budget").to_s

class Budget
  def self.change_phase
    change_active_phases
  end

  private

    def self.change_active_phases
      active_budgets.map do |budget|
        previous_phase = budget.phase
        next_phase = budget.published_phases.find do |phase|
          I18n.l(phase.starts_at.to_date) == I18n.l(Time.zone.now.to_date)
        end
        if next_phase.present?
          budget.phase = next_phase.kind
          if budget.save
            message = I18n.t("budget_change_active_phases.success",
                            budget_name: budget.name,
                            previous_phase: I18n.t("budgets.phase.#{previous_phase}"),
                            next_phase: I18n.t("budgets.phase.#{next_phase.kind}"))
            Mailer.budget_change_active_phases(self, message).deliver_later
          else
            Mailer.budget_change_active_phases(self, I18n.t("budget_change_active_phases.error")).deliver_later
          end
        end
      end
    end
end
