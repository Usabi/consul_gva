class Legislator::Exporter
  require "csv"
  include JsonExporter

  def initialize(legislators)
    @legislators = legislators
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @legislators.each { |legislator| csv << csv_values(legislator) }
    end
  end

  def model
    Legislator
  end

  private

    def headers
      [
        I18n.t("activerecord.attributes.legislator.id"),
        I18n.t("activerecord.attributes.user.username"),
        I18n.t("activerecord.attributes.user.email"),
        I18n.t("activerecord.attributes.legislator.description")
      ]
    end

    def csv_values(legislator)
      [
        legislator.id.to_s,
        legislator.user.username,
        legislator.email,
        legislator.description
      ]
    end
end
