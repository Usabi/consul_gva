load Rails.root.join("app", "controllers", "admin", "managers_controller.rb")

class Admin::ManagersController
  def index
    @managers = @managers.page(params[:page]) unless request.format.csv?
    respond_to do |format|
      format.html
      format.csv do
        send_data Manager::Exporter.new(@managers).to_csv,
                  filename: "managers.csv"
      end
    end
  end

  def search
    @users = User.search(params[:search]).includes(:manager)
    @users = @users.page(params[:page]) unless request.format.csv?
    respond_to do |format|
      format.html
      format.csv do
        managers = @users.map(&:manager).compact
        send_data Manager::Exporter.new(managers).to_csv,
                  filename: "managers.csv"
      end
    end
  end
end
