class FooterLink < ApplicationRecord
  URL_FORMAT = %r{\A(https?://[^\s/$.?#][^\s]*|/(?!/)[^\s]*)\z}i

  translates :label, touch: true
  include Globalizable

  validates_translation :label, presence: true, length: { maximum: 80 }
  validates :url, presence: true
  validates :url, length: { maximum: 255 }, format: { with: URL_FORMAT }, allow_blank: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :visible, -> { where(visible: true).order(:position, :id) }
  scope :sorted, -> { order(:position, :id) }

  def human_name
    label
  end
end
