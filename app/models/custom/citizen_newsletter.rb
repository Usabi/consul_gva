class CitizenNewsletter < ApplicationRecord
  STATUSES = %w[pending sent failed].freeze

  has_many :citizen_newsletter_proposals, dependent: :destroy
  has_many :most_supported_proposals, through: :citizen_newsletter_proposals, source: :proposal

  has_many :citizen_newsletter_debates, dependent: :destroy
  has_many :active_debates, through: :citizen_newsletter_debates, source: :debate

  has_many :citizen_newsletter_preview_processes, dependent: :destroy
  has_many :preview_processes, through: :citizen_newsletter_preview_processes,
                               source: :process, class_name: "Legislation::Process"

  has_many :citizen_newsletter_public_processes, dependent: :destroy
  has_many :public_processes, through: :citizen_newsletter_public_processes,
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
    return unless pending? || failed?

    subscribers = User.newsletter
                      .where("newsletter_debates = ? OR " \
                             "newsletter_proposals = ? OR " \
                             "newsletter_legislation = ?",
                             true, true, true)
    sent_count = 0
    subscribers.find_each do |user|
      should_send = (user.newsletter_proposals && most_supported_proposals.any?) ||
                    (user.newsletter_debates && active_debates.any?) ||
                    (user.newsletter_legislation && (preview_processes.any? || public_processes.any?))

      if should_send
        user.add_subscriptions_token
        if Rails.env.development?
          Mailer.citizen_newsletter(self, user).deliver_now
        else
          Mailer.citizen_newsletter(self, user).deliver_later
        end
        sent_count += 1
      else
        Rails.logger.info "Skipping user ##{user.id}: no matching content for preferences"
      end
    end
    true
  end
end
