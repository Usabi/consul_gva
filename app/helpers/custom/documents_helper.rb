module Custom::DocumentsHelper
  def fixed_document_item_link(document)
    info_text = "#{document.humanized_content_type} | #{number_to_human_size(document.attachment_file_size)}"

    document.fix_attachment_path if !File.exist?(document.attachment.path)

    link_to safe_join([document.title, tag.small("(#{info_text})")], " "),
            document.attachment.url,
            target: "_blank",
            title: t("shared.target_blank")
  end
end
