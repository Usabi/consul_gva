class Moderation::DocumentsController < Moderation::BaseController
  def index
    @documents = Document.hidden
                         .where(documentable_type: "Comment")
                         .includes(:user)
                         .order(hidden_at: :desc)
                         .page(params[:page])
  end
end
