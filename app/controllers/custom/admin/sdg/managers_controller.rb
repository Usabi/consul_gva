load Rails.root.join("app", "controllers", "admin", "sdg", "managers_controller.rb")

class Admin::SDG::ManagersController
  def index
    if params[:search]
      @users = User.accessible_by(current_ability).search(params[:search])
    else
      @users = User.accessible_by(current_ability).sdg_managers
    end
    @users = @users.page(params[:page]) unless request.format.csv?
    respond_to do |format|
      format.html
      format.csv do
        sdg_managers = @users.map(&:sdg_manager).compact
        send_data SDG::Manager::Exporter.new(sdg_managers).to_csv,
                  filename: "sdg_managers.csv"
      end
    end
  end
end
