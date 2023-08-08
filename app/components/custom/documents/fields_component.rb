class Documents::FieldsComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "documents", "fields_component")

class Documents::FieldsComponent
  attr_reader :f, :consult_document

  def initialize(f, consult_document)
    @f = f
    @consult_document = consult_document
  end
end
