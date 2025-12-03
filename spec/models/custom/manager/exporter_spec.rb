require "rails_helper"

describe Manager::Exporter do
  it_behaves_like "csv exporter",
                  :manager,
                  Manager::Exporter,
                  ["ID", "Username", "Email"]
end
