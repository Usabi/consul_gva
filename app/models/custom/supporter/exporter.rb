class Supporter::Exporter
  require "csv"
  include JsonExporter

  def initialize(supporters)
    @supporters = supporters
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @supporters.each { |supporter| csv << csv_values(supporter) }
    end
  end

  def model
    Supporter
  end

  private

    def headers
      [
        I18n.t("activerecord.attributes.supporter.id"),
        I18n.t("activerecord.attributes.user.username"),
        I18n.t("activerecord.attributes.user.email"),
        I18n.t("activerecord.attributes.supporter.description")
      ]
    end

    def csv_values(supporter)
      [
        supporter.id.to_s,
        supporter.user.username,
        supporter.email,
        supporter.description
      ]
    end
end
