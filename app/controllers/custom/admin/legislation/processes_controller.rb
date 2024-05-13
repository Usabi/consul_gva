require_dependency Rails.root.join("app", "controllers", "admin", "legislation", "processes_controller").to_s

class Admin::Legislation::ProcessesController
  include Search

  def index
    @processes = ::Legislation::Process.send(@current_filter)
    if @search_terms.present?
      if @search_terms.to_i.positive?
        @processes = @processes.where(id: @search_terms)
      else
        @processes = @processes.search(@search_terms)
      end
    end

    @processes = @processes.order(start_date: :desc).accessible_by(current_ability)
                 .page(params[:page])
  end

  def create
    @process.user = current_user
    if @process.save
      link = legislation_process_path(@process)
      notice = t("admin.legislation.processes.create.notice", link: link)
      redirect_to edit_admin_legislation_process_path(@process), notice: notice
    else
      flash.now[:error] = t("admin.legislation.processes.create.error")
      render :new
    end
  end

  private

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
