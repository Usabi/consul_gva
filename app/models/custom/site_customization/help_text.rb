class SiteCustomization::HelpText < ApplicationRecord
  translates :title,       touch: true
  translates :content,     touch: true
  include Globalizable

  validates_translation :title, presence: true
  validates :section, presence: true,
                   uniqueness: { case_sensitive: false },
                   format: { with: /\A[0-9a-zA-Z_\/-]*\Z/, message: :section_format }

  scope :sort_asc, -> { order("id ASC") }
  scope :sort_desc, -> { order("id DESC") }
  scope :with_same_locale, -> { joins(:translations).locale }
  scope :locale, -> { where("site_customization_help_text_translations.locale": I18n.locale) }
end
