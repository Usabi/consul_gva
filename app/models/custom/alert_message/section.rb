class AlertMessage::Section < ApplicationRecord
  belongs_to :alert_message
  belongs_to :web_section
end
