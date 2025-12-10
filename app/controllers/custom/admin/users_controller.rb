load Rails.root.join("app", "controllers", "admin", "users_controller.rb")

class Admin::UsersController
  def index
    @users = @users.send(@current_filter)
    @users = @users.by_username_email_or_document_number(params[:search]) if params[:search]
    @users = @users.page(params[:page]) unless request.format.csv?
    respond_to do |format|
      format.html
      format.js
      format.csv do
        send_data User::Exporter.new(@users).to_csv,
                  filename: "users.csv"
      end
    end
  end
end
