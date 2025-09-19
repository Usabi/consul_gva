load Rails.root.join("app", "controllers", "admin", "legislation", "processes_controller.rb")

class Admin::Legislation::ProcessesController
  include Search
  include Admin::HelpPagesActions

  before_action :load_councils, only: [:index, :new, :create, :edit, :update]

  def index
    @processes = ::Legislation::Process.scoped_filter(params, @current_filter, @advanced_search_terms)

    @processes = @processes.accessible_by(current_ability)
                           .page(params[:page])
  end

  def create
    @process.user = current_user
    if @process.save
      default_question = @process.questions.last
      notice = t("admin.legislation.processes.create.notice", link: legislation_process_path(@process))
      if default_question.present?
        notice += "<br>" + t("admin.legislation.processes.default_question_created",
                             link: edit_admin_legislation_process_question_path(@process, default_question))
      else
        notice += "<br>" + t("admin.legislation.processes.default_question_creation_failed")
      end
      redirect_to edit_admin_legislation_process_path(@process), notice: notice
    else
      flash.now[:error] = t("admin.legislation.processes.create.error")
      render :new
    end
  end

  def help_page
    @help_text_content = help_text(controller_name)
    render "admin/legislation/processes/help_pages/show"
  end

  private

    def load_councils
      @councils = Legislation::Council.active
    end

    def allowed_params
      [
        :start_date,
        :end_date,
        :debate_start_date,
        :debate_end_date,
        :draft_start_date,
        :draft_end_date,
        :draft_publication_date,
        :allegations_start_date,
        :allegations_end_date,
        :proposals_phase_start_date,
        :proposals_phase_end_date,
        :result_publication_date,
        :debate_phase_enabled,
        :draft_phase_enabled,
        :allegations_phase_enabled,
        :proposals_phase_enabled,
        :draft_publication_enabled,
        :result_publication_enabled,
        :published,
        :council_id,
        :custom_list,
        :background_color,
        :font_color,
        :related_sdg_list,
        translation_params(::Legislation::Process),
        documents_attributes: document_attributes,
        image_attributes: image_attributes,
        legislator_ids: []
      ]
    end
end
