module Custom::PollsHelper
  def polls_tabs()
    tabs = {
      "polls" => admin_polls_path,
      }
    if current_user&.administrator? || (current_user&.legislator? && current_user == process.user)
      tabs = tabs.merge({ 'help_text' => help_page_admin_polls_path })
    end
    tabs
  end
end
