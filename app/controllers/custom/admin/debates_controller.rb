require_dependency Rails.root.join("app", "controllers", "admin", "debates_controller").to_s

class Admin::DebatesController
  include Admin::HelpPagesActions
  
  def help_page
    @help_text_content = help_text(controller_name)
    render "admin/debates/help_pages/show"
  end

  private

    def resource_model
      ::Debate
    end
end