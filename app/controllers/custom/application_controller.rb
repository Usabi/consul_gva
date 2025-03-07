load Rails.root.join("app", "controllers", "application_controller.rb")

class ApplicationController
  before_action :set_flash_alerts

  private

    def set_current_section
      case params[:controller]
      when "welcome"
        @current_section = "homepage"
      when "pages"
        @current_section = "help_page"
      else
        @current_section = params[:controller]
      end
    end

    def set_flash_alerts
      return if request.xhr? || params[:controller].start_with?("admin/")

      set_current_section
      active_alerts = AlertMessage.in_section(@current_section).with_active.uniq
      active_alerts.each do |alert|
        flash.now[alert.flash_key] = Shared::AlertMessageComponent.new(alert).render_in(view_context)
      end
    end
end
