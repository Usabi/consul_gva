load Rails.root.join("app", "controllers", "admin", "officials_controller.rb")

class Admin::OfficialsController
  def index
    @officials = User.officials.for_render
    @officials = @officials.page(params[:page]) unless request.format.csv?
    respond_to do |format|
      format.html
      format.csv do
        send_data User::Official::Exporter.new(@officials).to_csv,
                  filename: "officials.csv"
      end
    end
  end

  def search
    @users = User.search(params[:search]).for_render
    @users = @users.page(params[:page]) unless request.format.csv?
    respond_to do |format|
      format.html
      format.csv do
        send_data User::Official::Exporter.new(@users).to_csv,
                  filename: "officials.csv"
      end
    end
  end
end
