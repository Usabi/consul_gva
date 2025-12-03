require "rails_helper"

describe User::Official::Exporter do
  describe "#to_csv" do
    it "generates a CSV with headers" do
      users = create_list(:user, 2, official_level: 1)
      exporter = User::Official::Exporter.new(users)

      csv = exporter.to_csv

      expect(csv).to include(I18n.t("activerecord.attributes.user.id"))
      expect(csv).to include(I18n.t("activerecord.attributes.user.username"))
      expect(csv).to include(I18n.t("activerecord.attributes.user.email"))
      expect(csv).to include(I18n.t("activerecord.attributes.user.official_position"))
      expect(csv).to include(I18n.t("activerecord.attributes.user.official_level"))
    end

    it "includes record data in CSV" do
      user = create(:user, official_level: 1, username: "test_official")
      exporter = User::Official::Exporter.new([user])

      csv = exporter.to_csv

      expect(csv).to include(user.id.to_s)
      expect(csv).to include("test_official")
    end

    it "includes all records" do
      users = create_list(:user, 3, official_level: 1)
      exporter = User::Official::Exporter.new(users)

      csv = exporter.to_csv
      parsed_csv = CSV.parse(csv, headers: true)

      expect(parsed_csv.count).to eq(3)
    end

    it "generates valid CSV format" do
      users = create_list(:user, 2, official_level: 1)
      exporter = User::Official::Exporter.new(users)

      csv = exporter.to_csv

      expect { CSV.parse(csv, headers: true) }.not_to raise_error
    end

    it "includes official position and level" do
      user = create(:user, official_position: "Director", official_level: 1)
      exporter = User::Official::Exporter.new([user])

      csv = exporter.to_csv

      expect(csv).to include("Director")
      expect(csv).to include("1")
    end

    it "handles officials with level 0" do
      user = create(:user, official_level: 0)
      exporter = User::Official::Exporter.new([user])

      csv = exporter.to_csv

      expect { CSV.parse(csv, headers: true) }.not_to raise_error
      expect(csv).to include("0")
    end
  end
end
