
require_dependency Rails.root.join("app", "controllers", "admin", "organizations_controller").to_s

class Admin::OrganizationsController
  has_filters %w[pending all verified rejected], only: [:index, :search]

  load_and_authorize_resource

  def index
    @organizations = @organizations.send(@current_filter)
    @organizations = @organizations.includes(:user)
                                    .order("users.created_at", :name, "users.email")
    @organizations = @organizations.page(params[:page]) unless request.format.csv?
    respond_to do |format|
      format.html
      format.csv do
        send_data Organization::Exporter.new(@organizations).to_csv,
                  filename: "organizations.csv"
      end
    end
  end

  def search
    @organizations = @organizations.send(@current_filter)
    @organizations = @organizations.includes(:user)
                                    .search(params[:search])
                                    .order("users.created_at", :name, "users.email")

    @organizations = @organizations.page(params[:page]) unless request.format.csv?
    respond_to do |format|
      format.html
      format.csv do
        send_data Organization::Exporter.new(@organizations).to_csv,
                  filename: "organizations.csv"
      end
    end
  end

end
