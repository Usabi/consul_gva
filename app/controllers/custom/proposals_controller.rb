load Rails.root.join("app", "controllers", "proposals_controller.rb")

class ProposalsController
  def retire_form
    @proposal = Proposal.find(params[:id])
    @proposal.retired_reason = params[:retired_reason] if params[:retired_reason].present?
    @proposal.retired_explanation = params[:retired_explanation] if params[:retired_explanation].present?
  end
end
