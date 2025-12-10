load Rails.root.join("app", "controllers", "admin", "moderators_controller.rb")

class Admin::ModeratorsController
  def index
    @moderators = @moderators.page(params[:page]) unless request.format.csv?
    respond_to do |format|
      format.html
      format.csv do
        send_data Moderator::Exporter.new(@moderators).to_csv,
                  filename: "moderators.csv"
      end
    end
  end

  def search
    @users = User.search(params[:search]).includes(:moderator)
    @users = @users.page(params[:page]) unless request.format.csv?
    respond_to do |format|
      format.html
      format.csv do
        moderators = @users.map(&:moderator).compact
        send_data Moderator::Exporter.new(moderators).to_csv,
                  filename: "moderators.csv"
      end
    end
  end
end
