class Bulletin < ApplicationRecord
  TEMPLATE = %w[proposal
                debate
                legislation_process_preview_phase
                legislation_process_public_phase
                legislation_process_past].freeze

  MAX_DISPLAY_DATES = 5

  validates :title, presence: true
  validates :template, presence: true

  def add_sent_at_date(date = Time.zone.now)
    sent_at_dates << date
    save!
  end

  def ordered_sent_at_dates
    sent_at_dates.present? ? sent_at_dates.reverse.map { |d| format_time(Time.zone.parse(d)) } : "-"
  end

  def last_send_date
    sent_at_dates.present? ? format_time(Time.zone.parse(sent_at_dates.last)) : "-"
  end

  def display_sent_at_dates
    case sent_at_dates.size
    when 0
      "-"
    when 1..MAX_DISPLAY_DATES
      ordered_sent_at_dates.join(", ")
    else
      ordered_sent_at_dates.first(MAX_DISPLAY_DATES).join(", ")
    end
  end

  def show_full_sent_at_dates_tooltip?
    sent_at_dates.size > MAX_DISPLAY_DATES
  end

  def format_time(time)
    time.strftime("%Y-%m-%d %H:%M")
  end
end
