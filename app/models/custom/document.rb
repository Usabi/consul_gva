require_dependency Rails.root.join("app", "models", "document").to_s

class Document
  after_update :fix_attachment_path, if: :saved_change_to_title?

  # NOTE: Fix filename broken when document title changed
  def fix_attachment_path
    return if File.exist?(attachment.path)

    folder = File.dirname(attachment.path)
    return unless Dir.exist?(folder)

    file_path = Dir[folder + '/*'].sort_by {|f| File.stat(f).mtime }.last
    return unless file_path && File.exist?(file_path)

    File.rename(file_path, attachment.path)
  end
end
