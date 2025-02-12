require_dependency Rails.root.join("app", "models", "newsletter").to_s

class Newsletter
  serialize :segment_recipient, Array

  before_validation :sanitize_segment_recipient

  validates :segment_recipient, presence: true, if: :segment_recipient_present?

  def valid_segment_recipient?
    segment_recipient.all? { |segment| UserSegments.valid_segment?(segment) }
  end
  
  private

    def sanitize_segment_recipient
      self.segment_recipient = segment_recipient.reject(&:blank?)
    end

    def segment_recipient_present?
      segment_recipient.present? && segment_recipient.is_a?(Array) && segment_recipient.any?
    end

    def validate_segment_recipient
      errors.add(:segment_recipient, :invalid) unless valid_segment_recipient?
    end
end