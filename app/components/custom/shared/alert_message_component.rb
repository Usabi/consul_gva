class Shared::AlertMessageComponent < ApplicationComponent
  attr_reader :alert_message_or_section

  def initialize(alert_message_or_section)
    @alert_message_or_section = alert_message_or_section
  end

  def alert_message
    @alert_message ||= if alert_message_or_section.respond_to?(:sections)
                         alert_message_or_section
                       else
                         AlertMessage.in_section(alert_message_or_section).with_active.uniq
                       end
  end

  private

    def link
      link_to alert_message.target_url do
        tag.h6(alert_message.title) +
          tag.p(alert_message.description)
      end
    end
end
