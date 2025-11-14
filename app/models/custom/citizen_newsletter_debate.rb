class CitizenNewsletterDebate < ApplicationRecord
  belongs_to :citizen_newsletter
  belongs_to :debate

  validates :citizen_newsletter_id, uniqueness: { scope: :debate_id }
end
