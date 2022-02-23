require_dependency Rails.root.join('app', 'controllers', 'legislation', 'processes_controller').to_s

class Legislation::ProcessesController
  def summary
    @phase = :summary
    @proposals = @process.proposals.selected
    @comments = (params[:format] == "xlsx" ? @process.draft_versions.published.last&.all_comments : @process.draft_versions.published.last&.best_comments) || Comment.none
    respond_to do |format|
      format.html
      format.xlsx { render xlsx: "summary", filename: "summary-#{Date.current}.xlsx" }
    end
  end
end
