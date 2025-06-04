require_dependency Rails.root.join("app", "models", "organization").to_s

class Organization < ApplicationRecord
  def self.search(text)
    if text.present?
      joins(:user).where(
      "users.email = ? OR users.phone_number = ? OR organizations.name ILIKE ? OR organizations.responsible_name ILIKE ?", text, text, "%#{text}%", "%#{text}%"
      )
    else
      none
    end
  end
end
