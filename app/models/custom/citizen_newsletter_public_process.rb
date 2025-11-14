class CitizenNewsletterPublicProcess < ApplicationRecord
  belongs_to :citizen_newsletter
  belongs_to :process, class_name: "Legislation::Process"

  validates :citizen_newsletter_id, uniqueness: { scope: :process_id }
end
