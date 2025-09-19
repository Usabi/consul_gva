class Legislation::Council < ApplicationRecord
  acts_as_paranoid column: :hidden_at
  
  has_many :processes, class_name: "Legislation::Process", foreign_key: "council_id", dependent: :nullify, inverse_of: :council

  translates :title, touch: true
  include Globalizable

  validates :title, presence: true
  validates_translation :title, presence: true

  scope :active, -> { where(active: true) }
end
