require "rails_helper"

describe SDG::Manager::Exporter do
  it_behaves_like "csv exporter",
                  :sdg_manager,
                  SDG::Manager::Exporter,
                  [
                    I18n.t("activerecord.attributes.sdg/manager.id"),
                    I18n.t("activerecord.attributes.user.username"),
                    I18n.t("activerecord.attributes.user.email")
                  ]
end
