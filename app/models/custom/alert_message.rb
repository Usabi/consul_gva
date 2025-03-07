class AlertMessage < ApplicationRecord
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  has_many :sections, dependent: :destroy
  has_many :web_sections, through: :sections

  FLASH_KEYS = %w[notice primary warning alert].freeze

  after_initialize :set_defaults, unless: :persisted?

  translates :title,       touch: true
  translates :description, touch: true
  include Globalizable

  validates_translation :title, presence: true
  validates_translation :description, presence: true
  validates :title, length: { in: 2..80 }
  validates :description, length: { maximum: 150 }

  validates :target_url, presence: true

  scope :with_active, -> { where(active: true) }
  scope :with_inactive, -> { where.not(id: with_active) }
  scope :in_section, ->(section_name) do
    joins(:web_sections, :sections).where("web_sections.name ilike ?", section_name)
  end

  def enabled?
    active.present?
  end

  def text
    if enabled?
      I18n.t("shared.yes")
    else
      I18n.t("shared.no")
    end
  end

  private

    def set_defaults
      self.flash_key ||= FLASH_KEYS.first
      self.target_url ||= "#"
      self.active = true if active.nil?
    end
end
