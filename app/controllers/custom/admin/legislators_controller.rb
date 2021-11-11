class Admin::LegislatorsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @legislators = @legislators.page(params[:page])
  end

  def search
    @users = User.search(params[:name_or_email])
                 .includes(:legislator)
                 .page(params[:page])
                 .for_render
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
