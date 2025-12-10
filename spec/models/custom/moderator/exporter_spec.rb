require "rails_helper"

describe Moderator::Exporter do
  it_behaves_like "csv exporter",
                  :moderator,
                  Moderator::Exporter,
                  ["ID", "Username", "Email"]
end
