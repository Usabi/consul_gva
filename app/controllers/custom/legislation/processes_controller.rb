load Rails.root.join("app", "controllers", "legislation", "processes_controller.rb")

class Legislation::ProcessesController
  include CommentableActions

  before_action :load_categories, only: :index
  skip_before_action :set_search_order
  
  valid_filters = Legislation::Process.processes_filters
  has_filters valid_filters, only: :index

  # Overwrite index of CommentableActions
  def index
    @current_filter ||= "preview_phase"
    @processes = resource_model.send(@current_filter).published.not_in_draft

    if @search_terms.present?
      if @search_terms.to_i.positive?
        @advanced_search_terms ||= ActionController::Parameters.new
        @advanced_search_terms[:id] = @search_terms
      else
        @processes = @processes.search(@search_terms)
      end
    end

    @processes = advance_search_term_present? ? @processes.filter_by(@advanced_search_terms) : @processes
    @processes = @processes.page(params[:page]).order(order_by_phase)
    @tag_cloud = tag_cloud
  end

  def summary
    @phase = :summary
    @proposals = @process.proposals.selected
    @comments = (params[:format] == "xlsx" ? @process.draft_versions.published.last&.all_comments : @process.draft_versions.published.last&.best_comments) || Comment.none
    @stats = Legislation::Stats.new(@process)
    @summary_sections = summary_sections
    @active_section = @summary_sections.find { |section| section[:key] == params[:section] } || @summary_sections.first

    respond_to do |format|
      format.html
      format.xlsx { render xlsx: "summary", filename: "summary-#{@active_section&.dig(:key)}-#{Date.current}.xlsx" }
    end
  end

  private

    def summary_sections
      has_phases = @process.debate_phase.enabled? || @process.proposals_phase.enabled? ||
                   @process.allegations_phase.enabled?

      [
        { key: "debate", enabled: @process.debate_phase.enabled? },
        { key: "proposals", enabled: @process.proposals_phase.enabled? },
        { key: "allegations", enabled: @process.allegations_phase.enabled? },
        { key: "stats", enabled: has_phases }
      ].select { |section| section[:enabled] }
    end

    def resource_model
      Legislation::Process
    end

    def advance_search_term_present?
      @advanced_search_terms.present? && @advanced_search_terms.keys.map { |key| @advanced_search_terms[key].present? }.uniq.include?(true)
    end

    def order_by_phase
      phase_dates = {
        draft_phase: :draft_start_date,
        preview_phase: :debate_start_date,
        proposals_phase: :proposals_phase_start_date,
        public_phase: :allegations_start_date,
        results: :result_publication_date
      }
      { phase_dates[@current_filter.to_sym] || :start_date => :desc }
    end
end
