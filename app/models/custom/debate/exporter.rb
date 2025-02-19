class Debate::Exporter
  require "csv"
  include JsonExporter

  def initialize(debates)
    @debates = debates
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @debates.each { |debate| csv << csv_values(debate) }
    end
  end

  def model
    Debate
  end

  private

    def headers
      [
        I18n.t("admin.debates.index.list.id"),
        I18n.t("admin.debates.index.list.title"),
        I18n.t("admin.debates.index.list.author_username"),
        I18n.t("admin.debates.index.list.supports"),
        I18n.t("admin.debates.index.list.created_at"),
        I18n.t("admin.debates.index.list.sdg"),
        I18n.t("admin.debates.index.list.target"),
        I18n.t("admin.debates.index.list.tags")
      ]
    end

    def csv_values(debate)
      [
        debate.id.to_s,
        debate.title,
        debate.author.username,
        debate.total_votes.to_s,
        debate.created_at.strftime("%d/%m/%Y"),
        debate.sdg_goal_list.split(",").join(";").presence || "-",
        debate.sdg_target_list.split(",").join(";").presence || "-",
        debate.tags_list.join(";").presence || "-"
      ]
    end

    def json_values(debate)
      {
        id: debate.id,
        title: debate.title,
        description: strip_tags(debate.description)
      }
    end
end
