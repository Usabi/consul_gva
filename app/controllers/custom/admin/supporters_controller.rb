class Admin::SupportersController < Admin::BaseController
  load_and_authorize_resource

  def index
    @supporters = @supporters.page(params[:page])
  end

  def search
    @users = User.search(params[:search])
                 .includes(:supporter)
                 .page(params[:page])
  end

  def create
    @supporter.user_id = params[:user_id]
    @supporter.save!

    redirect_to admin_supporters_path
  end

  def edit
  end

  def update
    if @supporter.update(update_supporter_params)
      notice = t("admin.supporters.form.updated")
      redirect_to admin_supporters_path, notice: notice
    else
      render :edit
    end
  end

  def destroy
    @supporter.destroy!
    redirect_to admin_supporters_path
  end

  private

    def update_supporter_params
      params.require(:supporter).permit(allowed_params)
    end

    def allowed_params
      [:description]
    end
end
