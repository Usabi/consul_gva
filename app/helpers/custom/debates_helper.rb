module Custom::DebatesHelper
  def debates_tabs()
    tabs = {
      "debates" => admin_debates_path,
      }
    if current_user&.administrator? || (current_user&.legislator? && current_user == process.user)
      tabs = tabs.merge({ 'help_text' => help_page_admin_debates_path })
    end
    tabs
  end
end
