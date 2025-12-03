class Administrator::Exporter
  require "csv"
  include JsonExporter

  def initialize(administrators)
    @administrators = administrators
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @administrators.each { |administrator| csv << csv_values(administrator) }
    end
  end

  def model
    Administrator
  end

  private

    def headers
      [
        I18n.t("activerecord.attributes.administrator.id"),
        I18n.t("activerecord.attributes.user.username"),
        I18n.t("activerecord.attributes.user.email"),
        I18n.t("activerecord.attributes.administrator.description")
      ]
    end

    def csv_values(administrator)
      [
        administrator.id.to_s,
        administrator.user.username,
        administrator.email,
        administrator.description
      ]
    end
end
