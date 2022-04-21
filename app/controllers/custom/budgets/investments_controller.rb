require_dependency Rails.root.join('app', 'controllers', 'budgets', 'investments_controller').to_s
class Budgets::InvestmentsController
  # Rails.application.load_tasks # NOTE: En Valencia lo tienen pero no sé si es necesario (igual hace falta si pasa algo con tareas)

  PER_PAGE = 20

  before_action :load_headings, only: [:index, :new, :create, :vote, :unvote]
  before_action :load_votes, only: [:index, :show]
  before_action :load_categories, only: [:index, :new, :create, :vote, :unvote, :edit, :update]

  valid_filters = %w[not_unfeasible feasible unfeasible unselected selected winners not_selected]
  has_filters valid_filters, only: [:index, :show, :suggest]

  def index
    session["create_investment_back_path"] = request.fullpath
    session["ballot_referer"] = request.env["REQUEST_URI"]
    @back_link_map_path = session[:back_link_map_path].present? ? session[:back_link_map_path] : budget_path(@budget)
    session[:back_link_investment_list] = request.fullpath
    @investments = investments.page(params[:page]).per(PER_PAGE).for_render
    @investment_ids = @investments.ids
    @investments_map_coordinates = MapLocation.where(investment: investments).map(&:json_data)
    @tag_cloud = tag_cloud
    @remote_translations = detect_remote_translations(@investments)
  end


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



  private
    def load_categories
      @categories = Tag.category.order(name: :desc)
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
