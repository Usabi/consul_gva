class Comments::DocumentsComponent < ApplicationComponent
  attr_reader :comment
  delegate :can?, to: :helpers

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
