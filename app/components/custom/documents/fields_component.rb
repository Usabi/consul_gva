class Documents::FieldsComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "documents", "fields_component.rb")

class Documents::FieldsComponent
  attr_reader :f, :consult_document

  def initialize(f, consult_document)
    @f = f
    @consult_document = consult_document
  end
end
