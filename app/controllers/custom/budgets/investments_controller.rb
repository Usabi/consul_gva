require_dependency Rails.root.join('app', 'controllers', 'budgets', 'investments_controller').to_s
class Budgets::InvestmentsController
  # Rails.application.load_tasks # NOTE: En Valencia lo tienen pero no sé si es necesario (igual hace falta si pasa algo con tareas)

  before_action :load_headings, only: [:index, :new, :create, :vote, :unvote]
  before_action :load_votes, only: [:index, :show]
  before_action :load_categories, only: [:index, :new, :create, :vote, :unvote, :edit, :update]

  valid_filters = %w[not_unfeasible feasible unfeasible unselected selected winners not_selected]
  has_filters valid_filters, only: [:index, :show, :suggest]

  def unvote
    @investment.register_selection_vote_and_unvote(current_user, "no")
    load_investment_votes(@investment)
    @tag_cloud = tag_cloud
    load_votes
    respond_to do |format|
      format.html { redirect_to budget_investments_path(heading_id: @investment.heading.id) }
      format.js
    end
  end

  def vote
    @investment.register_selection(current_user)
    load_investment_votes(@investment)
    @tag_cloud = tag_cloud
    load_votes
    respond_to do |format|
      format.html { redirect_to budget_investments_path(heading_id: @investment.heading.id) }
      format.js
    end
  end

  def index
    investments_per_page = 20
    session["create_investment_back_path"] = request.fullpath
    session["ballot_referer"] = request.env["REQUEST_URI"]
    @back_link_map_path = session[:back_link_map_path].present? ? session[:back_link_map_path] : budget_path(@budget)
    session[:back_link_investment_list] = request.fullpath
    @investments = investments.page(params[:page]).per(investments_per_page).for_render

    @investment_ids = @investments.pluck(:id)
    load_investment_votes(@investments)
    @tag_cloud = tag_cloud
  end

  private
    def load_categories
      @categories = ActsAsTaggableOn::Tag.category.order(name: :desc)
    end

    def load_headings
      @headings = @budget.headings.all.order(name: :asc)
    end

    def load_votes
      if current_user
        @votes = current_user.voted_budget_investments(@budget.id)
      end
    end
end
