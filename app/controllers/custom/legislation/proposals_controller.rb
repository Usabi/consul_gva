load Rails.root.join("app", "controllers", "legislation", "proposals_controller.rb")

class Legislation::ProposalsController
  rescue_from CanCan::AccessDenied do |exception|
    if %w[edit update].include?(action_name) && @proposal&.persisted?
      redirect_to legislation_process_proposal_path(@process || @proposal.process, @proposal),
                  alert: edit_denied_message(@proposal, exception)
    else
      respond_to do |format|
        format.html { redirect_to main_app.root_path, alert: exception.message }
        format.json { render json: { error: exception.message }, status: :forbidden }
      end
    end
  end

  private

    def edit_denied_message(proposal, exception)
      if proposal.total_votes.positive?
        t("legislation.proposals.edit_denied.supports")
      elsif proposal.process.end_date < Date.current
        t("legislation.proposals.edit_denied.process_closed")
      elsif !proposal.process.proposals_phase.open?
        t("legislation.proposals.edit_denied.closed")
      else
        exception.message
      end
    end
end
