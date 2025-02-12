module UserSegmentsHelper
  def user_segments_options
    UserSegments.segments.map do |user_segment_name|
      [segment_name(user_segment_name), user_segment_name]
    end
  end

  def segment_name(user_segment)
    # Custom

    segments = Array(user_segment)
    names = segments.map { |segment| UserSegments.segment_name(segment) }.compact
    names.any? ? names.join(", ") : I18n.t("admin.segment_recipient.invalid_recipients_segment")
  end
end
