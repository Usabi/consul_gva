class ManagementNewsletter < ApplicationRecord
  STATUSES = %w[pending sent failed].freeze

  has_many :management_newsletter_proposals, dependent: :destroy
  has_many :most_supported_proposals, through: :management_newsletter_proposals, source: :proposal

  has_many :management_newsletter_debates, dependent: :destroy
  has_many :active_debates, through: :management_newsletter_debates, source: :debate

  has_many :management_newsletter_preview_processes, dependent: :destroy
  has_many :preview_processes, through: :management_newsletter_preview_processes,
                               source: :process, class_name: "Legislation::Process"

  has_many :management_newsletter_public_processes, dependent: :destroy
  has_many :public_processes, through: :management_newsletter_public_processes,
                              source: :process, class_name: "Legislation::Process"

  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :newest_first, -> { order(created_at: :desc) }

  def pending?
    status == "pending"
  end

  def sent?
    status == "sent"
  end

  def failed?
    status == "failed"
  end

  def status_class
    case status
    when "pending" then "warning"
    when "sent" then "success"
    when "failed" then "alert"
    end
  end

  def mark_as_sent
    update(status: "sent", sent_at: Time.zone.now)
  end

  def mark_as_failed
    update(status: "failed")
  end

  def deliver
    Mailer.management_newsletter(self).deliver_later if pending? || failed?
  end
end
