module Custom::ProposalsHelper
  def budget_phase_selecting?
    Budget.find_by(phase: "selecting").present?
  end

  def proposals_tabs()
    tabs = {
      "proposals" => admin_proposals_path,
      }
    if current_user&.administrator? || (current_user&.legislator? && current_user == process.user)
      tabs = tabs.merge({ 'help_text' => help_page_admin_proposals_path })
    end
    tabs
  end
end
