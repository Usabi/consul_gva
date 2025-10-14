class ManagementNewsletterPreviewProcess < ApplicationRecord
  belongs_to :management_newsletter
  belongs_to :process, class_name: "Legislation::Process"
end
