
class Documents::NestedComponent < ApplicationComponent; end
require_dependency Rails.root.join("app", "components", "documents", "nested_component")

class Documents::NestedComponent
  attr_reader :f, :consult_document

  def initialize(f, consult_document = false)
    @f = f
    @consult_document = consult_document
  end

  def max_documents_allowed?
    documentable.documents.where(consult_document: consult_document).count >= max_documents_allowed
  end
end
