class Valuator::Exporter
  require "csv"
  include JsonExporter

  def initialize(valuators)
    @valuators = valuators
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @valuators.each { |valuator| csv << csv_values(valuator) }
    end
  end

  def model
    Valuator
  end

  private

    def headers
      [
        I18n.t("activerecord.attributes.valuator.id"),
        I18n.t("admin.valuators.index.name"),
        I18n.t("admin.valuators.index.email"),
        I18n.t("admin.valuators.index.description"),
        I18n.t("admin.valuators.index.group"),
        I18n.t("admin.valuators.index.abilities")
      ]
    end

    def csv_values(valuator)
      [
        valuator.id.to_s,
        valuator.name,
        valuator.email,
        valuator.description,
        valuator.valuator_group&.name,
        valuator_abilities(valuator)
      ]
    end

    def valuator_abilities(valuator)
      abilities = []
      abilities << I18n.t("admin.valuators.index.can_comment") if valuator.can_comment?
      abilities << I18n.t("admin.valuators.index.can_edit_dossier") if valuator.can_edit_dossier?
      abilities.join(", ")
    end
end
