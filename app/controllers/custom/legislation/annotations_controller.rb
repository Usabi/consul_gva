load Rails.root.join("app", "controllers", "legislation", "annotations_controller.rb")

class Legislation::AnnotationsController
  def create
    if !@process.allegations_phase.open? || @draft_version.final_version?
      render(json: {}, status: :not_found) && return
    end

    existing_annotation = @draft_version.annotations.find_by(
      range_start: annotation_params[:ranges].first[:start],
      range_start_offset: annotation_params[:ranges].first[:startOffset].to_i,
      range_end: annotation_params[:ranges].first[:end],
      range_end_offset: annotation_params[:ranges].first[:endOffset].to_i
    )

    errors = attachment_errors(annotation_params[:attachment])
    render(json: errors, status: :unprocessable_entity) && return if errors.any?

    @annotation = existing_annotation
    if @annotation.present?
      create_comment_on_existing_annotation
    else
      create_annotation
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: e.record.errors.full_messages, status: :unprocessable_entity
  end

  def new_comment
    @annotation = @annotations.find(params[:annotation_id])
    @comment = @annotation.comments.new(body: params[:comment][:body], user: current_user)
    build_attached_document

    if @comment.save
      @comment = @annotation.comments.new
    end

    respond_to do |format|
      format.js { render :new_comment }
    end
  end

  private

    def create_comment_on_existing_annotation
      comment = @annotation.comments.build(body: annotation_params[:text], user: current_user)
      attach_document(comment, annotation_params[:attachment])

      if comment.save
        render_annotation
      else
        render json: comment.errors.full_messages, status: :unprocessable_entity
      end
    end

    # Annotator posts through ajax and expects JSON. A plain form submit (for
    # example when the page scripts are outdated) goes back to the draft.
    def render_annotation
      if request.xhr? || request.format.json?
        render json: @annotation.to_json
      else
        redirect_to legislation_process_draft_version_path(@process, @draft_version)
      end
    end

    def create_annotation
      @annotation = @draft_version.annotations.new(annotation_params)
      @annotation.author = current_user

      if @annotation.save
        render_annotation
      else
        render json: @annotation.errors.full_messages, status: :unprocessable_entity
      end
    end

    def allowed_params
      [:quote, :text, :attachment, ranges: [:start, :startOffset, :end, :endOffset]]
    end

    def attachment_errors(attachment)
      return [] if attachment.blank? || !attachment.respond_to?(:original_filename)

      document = Document.new(user: current_user, title: attachment.original_filename,
                              documentable_type: "Comment", attachment: attachment)
      document.valid?
      document.errors.full_messages
    end

    def attach_document(comment, attachment)
      return if attachment.blank? || !attachment.respond_to?(:original_filename)

      comment.documents.build(user: current_user,
                              title: attachment.original_filename,
                              attachment: attachment)
    end

    def build_attached_document
      attach_document(@comment, params.dig(:comment, :attachment))
    end
end
