class User::Exporter
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
        I18n.t("admin.users.columns.name"),
        I18n.t("admin.users.columns.email"),
        I18n.t("admin.users.columns.document_number"),
        I18n.t("admin.users.columns.roles"),
        I18n.t("admin.users.columns.verification_level"),
        I18n.t("admin.users.columns.activation_status"),
        I18n.t("admin.users.columns.postal_code"),
        I18n.t("admin.users.columns.services_results"),
        I18n.t("activerecord.attributes.user.created_at")
      ]
    end

    def csv_values(user)
      status = if user.confirmed_at?
                 I18n.t("admin.users.account.active_status")
               else
                 I18n.t("admin.users.account.inactive_status")
               end
      [
        user.id.to_s,
        user.name,
        user.email,
        user.document_number,
        user_roles(user),
        user.user_type,
        status,
        user.postal_code,
        user.services_results,
        I18n.l(user.created_at, format: :datetime)
      ]
    end

    def user_roles(user)
      roles = []
      roles << I18n.t("admin.users.index.administrator") if user.administrator?
      roles << I18n.t("admin.users.index.moderator") if user.moderator?
      roles << I18n.t("admin.users.index.valuator") if user.valuator?
      roles << I18n.t("admin.users.index.manager") if user.manager?
      roles << I18n.t("admin.users.index.poll_officer") if user.poll_officer?
      roles.join(", ")
    end
end
