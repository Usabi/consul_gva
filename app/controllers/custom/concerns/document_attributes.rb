require_dependency Rails.root.join("app", "controllers", "concerns", "document_attributes").to_s


module DocumentAttributes
  extend ActiveSupport::Concern

  def document_attributes
    [:id, :title, :attachment, :cached_attachment, :consult_document, :user_id, :_destroy]
  end
end
