class Users::PublicActivityComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "users", "public_activity_component.rb")

class Users::PublicActivityComponent
  def valid_filters
    @valid_filters ||= [
      ("proposals" if feature?(:proposals)),
      ("debates" if feature?(:debates)),
      ("budget_investments" if feature?(:budgets)),
      ("legislation_processes" if feature?("process.legislation")),
      "attached_documents",
      "comments",
      ("follows" if valid_interests_access?(user))
    ].compact.select { |filter| send(filter).any? }
  end

  def render_user_partial(filter)
    if filter == "legislation_processes"
      render "users/#{filter}", "#{filter}": send(filter).order(created_at: :desc).page(page), user: user
    else
      render "users/#{filter}", "#{filter}": send(filter).order(created_at: :desc).page(page)
    end
  end

  private

    def legislation_processes
      process_ids = []

      process_ids += Legislation::Question.joins(:comments)
                                          .where(comments: { user_id: user.id })
                                          .pluck(:legislation_process_id)

      process_ids += Legislation::Proposal.where(author: user).pluck(:legislation_process_id)

      process_ids += Legislation::Proposal.joins(:comments)
                                          .where(comments: { user_id: user.id })
                                          .pluck(:legislation_process_id)

      process_ids += Legislation::DraftVersion.joins(:annotations)
                                              .where(legislation_annotations: { author_id: user.id })
                                              .pluck(:legislation_process_id)

      process_ids += Legislation::DraftVersion.joins(annotations: :comments)
                                              .where(comments: { user_id: user.id })
                                              .pluck(:legislation_process_id)

      Legislation::Process.where(id: process_ids.uniq).published
    end

    def attached_documents
      Document.where(user: user.id)
              .includes(:documentable)
              .where.not(admin: true)
              .where.not(documentable_type: "Milestone")
    end
end
