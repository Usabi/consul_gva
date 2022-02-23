require_dependency Rails.root.join("app", "models", "document").to_s

class Document
  def custom_hash_data(attachment)
    file_name = attachment.instance.original_filename.presence || attachment.original_filename
    "#{attachment.instance.user_id}/#{file_name}"
  end

  private

    def remove_cached_attachment
      document = Document.new(documentable: documentable,
                              cached_attachment: cached_attachment,
                              user: user,
                              remove: true,
                              original_filename: original_filename)
      document.set_attachment_from_cached_attachment
      document.attachment.destroy
    end
end
