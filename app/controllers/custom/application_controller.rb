require_dependency Rails.root.join("app", "controllers", "application_controller").to_s

class ApplicationController
  before_action :set_flash_alerts

  private

    def set_flash_alerts
      return if request.xhr?

      current_section = params[:controller]
      active_alerts = AlertMessage.in_section(current_section).with_active.uniq

      active_alerts.each do |alert|
        flash.now[alert.flash_key] = Shared::AlertMessageComponent.new(alert).render_in(view_context)
      end
    end
end
