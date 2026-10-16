class Dashboard::PollsController < Dashboard::BaseController
  include DocumentAttributes
  before_action :authorize_manage_polls
  before_action :load_poll, only: [:edit, :update, :destroy]

  def index
    @polls = Poll.for(proposal)
  end

  def new
    @poll = Poll.for(proposal).new
  end

  def create
    @poll = Poll.for(proposal).new(poll_params.merge(author: current_user))
    assign_question_defaults

    if @poll.save
      redirect_to proposal_dashboard_polls_path(proposal), notice: t("flash.actions.create.poll")
    else
      render :new
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      @poll.assign_attributes(poll_params)
      assign_question_defaults

      if @poll.save
        format.html do
          redirect_to proposal_dashboard_polls_path(proposal),
                      notice: t("flash.actions.update.poll")
        end

        format.json { head :no_content }
      else
        format.html { render :edit }
        format.json { render json: @poll.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if ::Poll::Voter.where(poll: @poll).any?
      redirect_to proposal_dashboard_polls_path(proposal), alert: t("dashboard.polls.poll.unable_notice")
    else
      @poll.destroy!

      redirect_to proposal_dashboard_polls_path(proposal), notice: t("dashboard.polls.poll.success_notice")
    end
  end

  private

    def load_poll
      @poll = Poll.for(proposal).includes(:questions).find(params[:id])
    end

    def assign_question_defaults
      @poll.questions.each do |question|
        next unless question.new_record?

        question.author = current_user
        question.proposal = proposal
      end
    end

    def poll_params
      params.require(:poll).permit(allowed_params)
    end

    def allowed_params
      [:name, :starts_at, :ends_at, :description, :results_enabled,
       questions_attributes: question_attributes]
    end

    def question_attributes
      [:id, :title, :_destroy,
       question_options_attributes: question_options_attributes]
    end

    def question_options_attributes
      [:id, :_destroy, :title, :description, :given_order,
       documents_attributes: document_attributes]
    end

    def authorize_manage_polls
      authorize! :manage_polls, proposal
    end
end
