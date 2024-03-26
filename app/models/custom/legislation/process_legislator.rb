class Legislation::ProcessLegislator < ApplicationRecord
  belongs_to :process
  belongs_to :legislator
end
