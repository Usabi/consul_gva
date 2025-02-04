require_dependency Rails.root.join("app", "models", "site_customization", "image").to_s

class SiteCustomization::Image
  VALID_IMAGES = {
    "logo_header" => [435, 85],
    "logo_header2" => [435, 85],
    "social_media_icon" => [470, 246],
    "social_media_icon_twitter" => [246, 246],
    "apple-touch-icon-200" => [200, 200],
    "auth_bg" => [1280, 1500],
    "budget_execution_no_image" => [800, 600],
    "budget_investment_no_image" => [800, 600],
    "favicon" => [16, 16],
    "map" => [420, 500],
    "logo_email" => [400, 80],
    "welcome_process" => [370, 185]
  }.freeze

  private

    def check_image
      return unless image.attached?

      unless image.analyzed?
        attachment_changes["image"].upload
        image.analyze
      end

      width = image.metadata[:width]
      height = image.metadata[:height]

      if name.in?(["logo_header", "logo_header2"])
        errors.add(:image, :image_width, required_width: required_width) if width > required_width
      else
        errors.add(:image, :image_width, required_width: required_width) unless width == required_width
      end

      errors.add(:image, :image_height, required_height: required_height) unless height == required_height
    end
end
