class Admin::LegislatorsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @legislators = @legislators.page(params[:page]) unless request.format.csv?
    respond_to do |format|
      format.html
      format.csv do
        send_data Legislator::Exporter.new(@legislators).to_csv,
                  filename: "legislators.csv"
      end
    end
  end

  def search
    @users = User.search(params[:search])
                 .includes(:legislator)
    @users = @users.page(params[:page]) unless request.format.csv?
    respond_to do |format|
      format.html
      format.csv do
        legislators = @users.map(&:legislator).compact
        send_data Legislator::Exporter.new(legislators).to_csv,
                  filename: "legislators.csv"
      end
    end
  end

  def create
    @legislator.user_id = params[:user_id]
    @legislator.save!

    redirect_to admin_legislators_path
  end

  def destroy
    @legislator.destroy!
    redirect_to admin_legislators_path
  end
end
