load Rails.root.join("app", "models", "widget", "card.rb")

class Widget::Card
  translates :link_url, touch: true
  translates :link_text_2, touch: true
  translates :link_url_2, touch: true
  globalize_accessors

  # class_eval do
  #   clear_validators!
  # end

  translation_class_delegate :middle
  translation_class_delegate :header
  translation_class_delegate :validate_url?

  validates :link_url, presence: true, if: :validate_url?
  validates_translation :link_url, presence: true, if: :validate_url?
  validates_translation :title, presence: true, unless: :middle

  def validate_url?
    return false if middle

    !header? || link_text.present?
  end

  def self.body
    where(header: false, middle: false, cardable_id: nil).sort_by_order
  end

  def self.middle
    distinct(true).where(middle: true).order(:id)
  end
end
