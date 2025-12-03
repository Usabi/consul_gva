require "rails_helper"

describe Valuator::Exporter do
  it_behaves_like "csv exporter",
                  :valuator,
                  Valuator::Exporter,
                  [
                    I18n.t("activerecord.attributes.valuator.id"),
                    I18n.t("admin.valuators.index.name"),
                    I18n.t("admin.valuators.index.email"),
                    I18n.t("admin.valuators.index.description"),
                    I18n.t("admin.valuators.index.group"),
                    I18n.t("admin.valuators.index.abilities")
                  ]

  describe "#to_csv" do
    it "includes valuator group name" do
      valuator_group = create(:valuator_group, name: "Health Valuators")
      valuator = create(:valuator, valuator_group: valuator_group)
      exporter = Valuator::Exporter.new([valuator])

      csv = exporter.to_csv

      expect(csv).to include("Health Valuators")
    end

    it "handles valuators without group" do
      valuator = create(:valuator, valuator_group: nil)
      exporter = Valuator::Exporter.new([valuator])

      csv = exporter.to_csv

      expect { CSV.parse(csv, headers: true) }.not_to raise_error
    end

    it "includes valuator abilities" do
      valuator = create(:valuator, can_comment: true, can_edit_dossier: true)
      exporter = Valuator::Exporter.new([valuator])

      csv = exporter.to_csv

      expect(csv).to include(I18n.t("admin.valuators.index.can_comment"))
      expect(csv).to include(I18n.t("admin.valuators.index.can_edit_dossier"))
    end
  end
end
