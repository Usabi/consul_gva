class Organization::Exporter
  require "csv"
  include JsonExporter

  def initialize(organizations)
    @organizations = organizations
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @organizations.each { |organization| csv << csv_values(organization) }
    end
  end

  def model
    Organization
  end

  private

    def headers
      [
        I18n.t("admin.organizations.index.list.id"),
        I18n.t("admin.organizations.index.list.name"),
        I18n.t("admin.organizations.index.list.email"),
        I18n.t("admin.organizations.index.list.phone_number"),
        I18n.t("admin.organizations.index.list.responsible_name"),
        I18n.t("admin.organizations.index.list.status")
      ]
    end

    def csv_values(organization)
      status = if organization.verified?
                  I18n.t("admin.organizations.index.verified")
                elsif organization.rejected?
                  I18n.t("admin.organizations.index.rejected")
                else
                  I18n.t("admin.organizations.index.pending")
                end
      [
        organization.id.to_s,
        organization.name,
        organization.email,
        organization.phone_number,
        organization.responsible_name,
        status
      ]
    end

end
