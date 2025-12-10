class User::Official::Exporter
  require "csv"
  include JsonExporter

  def initialize(users)
    @users = users
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @users.each { |user| csv << csv_values(user) }
    end
  end

  def model
    User
  end

  private

    def headers
      [
        I18n.t("activerecord.attributes.user.id"),
        I18n.t("activerecord.attributes.user.username"),
        I18n.t("activerecord.attributes.user.email"),
        I18n.t("activerecord.attributes.user.official_position"),
        I18n.t("activerecord.attributes.user.official_level")
      ]
    end

    def csv_values(user)
      [
        user.id.to_s,
        user.username,
        user.email,
        user.official_position,
        user.official_level.to_s
      ]
    end
end
