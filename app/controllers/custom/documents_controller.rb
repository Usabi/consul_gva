load Rails.root.join("app", "controllers", "documents_controller.rb")

class DocumentsController
  def hide
    @document.hide
    redirect_back fallback_location: root_path, notice: t("documents.actions.hide.notice")
  end

  def restore
    @document.restore
    redirect_back fallback_location: root_path, notice: t("documents.actions.restore.notice")
  end
end
