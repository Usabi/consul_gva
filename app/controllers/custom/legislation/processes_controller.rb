require_dependency Rails.root.join("app", "controllers", "legislation", "processes_controller").to_s

class Legislation::ProcessesController
  include CommentableActions

  before_action :load_categories, only: :index
  before_action :set_search_filter, only: :index
  skip_before_action :set_search_order
  has_filters Legislation::Process.processes_filters, only: :index
  # Overwrite index of CommentableActions
  def index
    @current_filter ||= "preview_phase"
    @processes = @search_terms.present? || advance_search_term_present? ? resource_model.all.published.not_in_draft : resource_model.send(@current_filter).published.not_in_draft

    if @search_terms.present?
      if @search_terms.to_i.positive?
        @advanced_search_terms ||= ActionController::Parameters.new
        @advanced_search_terms[:id] = @search_terms
      else
        @processes = @processes.search(@search_terms)
      end
    end

    @processes = advance_search_term_present? ? @processes.filter_by(@advanced_search_terms) : @processes
    @processes = @processes.page(params[:page]).order(start_date: :desc)
    @tag_cloud = tag_cloud
  end

  def summary
    @phase = :summary
    @proposals = @process.proposals.selected
    @comments = (params[:format] == "xlsx" ? @process.draft_versions.published.last&.all_comments : @process.draft_versions.published.last&.best_comments) || Comment.none
    respond_to do |format|
      format.html
      format.xlsx { render xlsx: "summary", filename: "summary-#{Date.current}.xlsx" }
    end
  end

  private

    def resource_model
      Legislation::Process
    end

    def advance_search_term_present?
      @advanced_search_terms.present? && @advanced_search_terms.keys.map { |key| @advanced_search_terms[key].present? }.uniq.include?(true)
    end

    def set_search_filter
      if (params[:search].present? || advance_search_present?) && params[:filter].blank?
        params[:filter] = "relevance"
      end
    end
end
