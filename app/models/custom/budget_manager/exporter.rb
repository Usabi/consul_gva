class BudgetManager::Exporter
  require "csv"
  include JsonExporter

  def initialize(budget_managers)
    @budget_managers = budget_managers
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @budget_managers.each { |budget_manager| csv << csv_values(budget_manager) }
    end
  end

  def model
    BudgetManager
  end

  private

    def headers
      [
        I18n.t("activerecord.attributes.budget_manager.id"),
        I18n.t("activerecord.attributes.user.username"),
        I18n.t("activerecord.attributes.user.email"),
        I18n.t("activerecord.attributes.budget_manager.description")
      ]
    end

    def csv_values(budget_manager)
      [
        budget_manager.id.to_s,
        budget_manager.user.username,
        budget_manager.email,
        budget_manager.description
      ]
    end
end
