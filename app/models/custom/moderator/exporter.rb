class Moderator::Exporter
  require "csv"
  include JsonExporter

  def initialize(moderators)
    @moderators = moderators
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @moderators.each { |moderator| csv << csv_values(moderator) }
    end
  end

  def model
    Moderator
  end

  private

    def headers
      [
        I18n.t("activerecord.attributes.moderator.id"),
        I18n.t("activerecord.attributes.user.username"),
        I18n.t("activerecord.attributes.user.email")
      ]
    end

    def csv_values(moderator)
      [
        moderator.id.to_s,
        moderator.user.username,
        moderator.email
      ]
    end
end
