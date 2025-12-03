load Rails.root.join("app", "controllers", "admin", "administrators_controller.rb")

class Admin::AdministratorsController
  def index
    @administrators = @administrators.page(params[:page]) unless request.format.csv?
    respond_to do |format|
      format.html
      format.csv do
        send_data Administrator::Exporter.new(@administrators).to_csv,
                  filename: "administrators.csv"
      end
    end
  end

  def search
    @users = User.search(params[:search]).includes(:administrator)
    @users = @users.page(params[:page]) unless request.format.csv?
    respond_to do |format|
      format.html
      format.csv do
        administrators = @users.map(&:administrator).compact
        send_data Administrator::Exporter.new(administrators).to_csv,
                  filename: "administrators.csv"
      end
    end
  end
end
