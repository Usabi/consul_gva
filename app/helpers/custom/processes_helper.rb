module Custom::ProcessesHelper
  def xls_comments(sheet, link, comments)
    nested_comments(sheet, link, comments)
  end

  def nested_comments(sheet, link, comments, indexes = [])
    comments.each_with_index do |comment, index|
      local_indexes = indexes + [index + 1]
      sheet.add_row ["#{local_indexes.join(".")} - #{comment.body}", t("legislation.summary.votes", count: comment.votes_score)]
      sheet.add_hyperlink location: comment_url(comment), ref: sheet.rows.last.cells.first
      sheet.rows.last.cells.first.style = link
      comment_document_rows(sheet, link, comment)
      nested_comments(sheet, link, comment.children, local_indexes) if comment.children?
    end
  end

  def comment_document_rows(sheet, link, comment)
    comment.documents.visible.each do |document|
      url = polymorphic_url(document.attachment)

      sheet.add_row [document.title, document.humanized_content_type, url]
      sheet.add_hyperlink location: url, ref: sheet.rows.last.cells.first
      sheet.add_hyperlink location: url, ref: sheet.rows.last.cells.last
      sheet.rows.last.cells.first.style = link
      sheet.rows.last.cells.last.style = link
    end
  end

  def legislation_processes_tabs
    tabs = {
      "processes" => admin_legislation_processes_path
    }
    if current_user&.administrator? || current_user&.legislator?
      tabs = tabs.merge({ "help_text" => help_page_admin_legislation_processes_path })
    end
    tabs
  end
end
