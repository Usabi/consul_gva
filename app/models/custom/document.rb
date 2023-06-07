require_dependency Rails.root.join("app", "models", "document").to_s

class Document
  # NOTE: Fix filename broken when document title changed. Used to be called after_update, might not be necessary after the migration to ActiveStorage
  def fix_attachment_path
    return if File.exist?(attachment.path)

    folder = File.dirname(attachment.path)
    return unless Dir.exist?(folder)

    file_path = Dir[folder + '/*'].sort_by {|f| File.stat(f).mtime }.last
    return unless file_path && File.exist?(file_path)

    File.rename(file_path, attachment.path)
  end
end
