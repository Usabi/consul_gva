class SDG::Manager::Exporter
  require "csv"
  include JsonExporter

  def initialize(sdg_managers)
    @sdg_managers = sdg_managers
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @sdg_managers.each { |sdg_manager| csv << csv_values(sdg_manager) }
    end
  end

  def model
    SDG::Manager
  end

  private

    def headers
      [
        I18n.t("activerecord.attributes.sdg/manager.id"),
        I18n.t("activerecord.attributes.user.username"),
        I18n.t("activerecord.attributes.user.email")
      ]
    end

    def csv_values(sdg_manager)
      [
        sdg_manager.id.to_s,
        sdg_manager.user.username,
        sdg_manager.email
      ]
    end
end
