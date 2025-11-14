module Custom::LegislationHelper
  def user_participation_in_process(process, user)
    {
      questions: user_questions_for_process(process, user),
      proposals: user_proposals_for_process(process, user),
      annotations: user_annotations_for_process(process, user),
      annotation_comments: user_annotation_comments_for_process(process, user)
    }
  end

  private

    def user_questions_for_process(process, user)
      process.questions.joins(:comments).where(comments: { user_id: user.id }).distinct
    end

    def user_proposals_for_process(process, user)
      process.proposals.left_joins(:comments)
             .where("legislation_proposals.author_id = :user_id OR comments.user_id = :user_id",
                    user_id: user.id)
             .distinct
    end

    def user_annotations_for_process(process, user)
      Legislation::Annotation.joins(:draft_version)
                             .left_joins(:comments)
                             .where(legislation_draft_versions: { legislation_process_id: process.id })
                             .where("legislation_annotations.author_id = :user_id OR " \
                                    "comments.user_id = :user_id",
                                    user_id: user.id)
                             .distinct
    end

    def user_annotation_comments_for_process(process, user)
      annotations = user_annotations_for_process(process, user)
      Comment.where(commentable: annotations, user_id: user.id)
    end
end

LegislationHelper.include Custom::LegislationHelper
