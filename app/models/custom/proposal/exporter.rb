class Proposal::Exporter
  require "csv"
  include JsonExporter

  def initialize(proposals)
    @proposals = proposals
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @proposals.each { |proposal| csv << csv_values(proposal) }
    end
  end

  def model
    Proposal
  end

  private

    def headers
      [
        I18n.t("admin.proposals.index.list.id"),
        I18n.t("admin.proposals.index.list.title"),
        I18n.t("admin.proposals.index.list.author_username"),
        I18n.t("admin.proposals.index.list.milestones"),
        I18n.t("admin.proposals.index.list.supports"),
        I18n.t("admin.proposals.index.list.created_at"),
        I18n.t("admin.proposals.index.list.sdg"),
        I18n.t("admin.proposals.index.list.tags"),
        I18n.t("admin.proposals.index.list.selected")
      ]
    end

    def csv_values(proposal)
      [
        proposal.id.to_s,
        proposal.title,
        proposal.author.username,
        proposal.milestones.count,
        proposal.total_votes.to_s,
        proposal.created_at.strftime("%d/%m/%Y"),
        proposal.related_sdg_list.split(",").join(";").presence || "-",
        proposal.tags_list.join(";").presence || "-",
        proposal.selected? ? I18n.t("shared.yes") : I18n.t("shared.no")
      ]
    end

    def json_values(proposal)
      {
        id: proposal.id,
        title: proposal.title,
        description: strip_tags(proposal.description)
      }
    end
end
