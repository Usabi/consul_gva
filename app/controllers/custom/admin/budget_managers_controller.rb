class Admin::BudgetManagersController < Admin::BaseController
  load_and_authorize_resource

  def index
    @budget_managers = @budget_managers.page(params[:page]) unless request.format.csv?
    respond_to do |format|
      format.html
      format.csv do
        send_data BudgetManager::Exporter.new(@budget_managers).to_csv,
                  filename: "budget_managers.csv"
      end
    end
  end

  def search
    @users = User.search(params[:search])
                 .includes(:budget_manager)
    @users = @users.page(params[:page]) unless request.format.csv?
    respond_to do |format|
      format.html
      format.csv do
        budget_managers = @users.map(&:budget_manager).compact
        send_data BudgetManager::Exporter.new(budget_managers).to_csv,
                  filename: "budget_managers.csv"
      end
    end
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
