load Rails.root.join("app", "controllers", "admin", "valuators_controller.rb")

class Admin::ValuatorsController
  def index
    @valuators = @valuators.page(params[:page]) unless request.format.csv?
    respond_to do |format|
      format.html
      format.csv do
        send_data Valuator::Exporter.new(@valuators).to_csv,
                  filename: "valuators.csv"
      end
    end
  end

  def search
    @users = User.search(params[:search]).includes(:valuator)
    @users = @users.page(params[:page]) unless request.format.csv?
    respond_to do |format|
      format.html
      format.csv do
        valuators = @users.map(&:valuator).compact
        send_data Valuator::Exporter.new(valuators).to_csv,
                  filename: "valuators.csv"
      end
    end
  end
end
