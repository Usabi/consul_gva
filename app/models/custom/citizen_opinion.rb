class CitizenOpinion < ApplicationRecord
  paginates_per 25

  validates :topic, presence: true
  validates :body, presence: true  
  EMAIL_REGEX = /\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z/
  validates :email, presence: true, format: { with: EMAIL_REGEX }
end
