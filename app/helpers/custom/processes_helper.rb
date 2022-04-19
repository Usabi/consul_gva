
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
      nested_comments(sheet, link, comment.children, local_indexes) if comment.children?
    end
  end
end
