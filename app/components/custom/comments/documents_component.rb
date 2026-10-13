class Comments::DocumentsComponent < ApplicationComponent
  attr_reader :comment
  use_helpers :can?

  def initialize(comment)
    @comment = comment
  end

  def render?
    documents.any?
  end

  private

    def documents
      @documents ||= can?(:hide, Document) ? comment.documents.to_a : comment.documents.visible.to_a
    end
end
