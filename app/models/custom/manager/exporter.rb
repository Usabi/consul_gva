class Manager::Exporter
  require "csv"
  include JsonExporter

  def initialize(managers)
    @managers = managers
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @managers.each { |manager| csv << csv_values(manager) }
    end
  end

  def model
    Manager
  end

  private

    def headers
      [
        I18n.t("activerecord.attributes.manager.id"),
        I18n.t("activerecord.attributes.user.username"),
        I18n.t("activerecord.attributes.user.email")
      ]
    end

    def csv_values(manager)
      [
        manager.id.to_s,
        manager.user.username,
        manager.email
      ]
    end
end
