class Admin::BudgetManagersController < Admin::BaseController
  load_and_authorize_resource

  def index
    @budget_managers = @budget_managers.page(params[:page])
  end

  def search
    @users = User.search(params[:search])
                 .includes(:budget_manager)
                 .page(params[:page])
  end

  def create
    @budget_manager.user_id = params[:user_id]
    @budget_manager.save!

    redirect_to admin_budget_managers_path
  end

  def destroy
    @budget_manager.destroy!
    redirect_to admin_budget_managers_path
  end
end
