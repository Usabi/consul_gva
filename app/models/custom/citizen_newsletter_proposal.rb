class CitizenNewsletterProposal < ApplicationRecord
  belongs_to :citizen_newsletter
  belongs_to :proposal

  validates :citizen_newsletter_id, uniqueness: { scope: :proposal_id }
end
