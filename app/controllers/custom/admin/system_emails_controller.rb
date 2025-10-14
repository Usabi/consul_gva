load Rails.root.join("app", "controllers", "admin", "system_emails_controller.rb")

class Admin::SystemEmailsController
  def index
    @system_emails = {
      proposal_notification_digest: %w[view preview_pending],
      duplicated_proposal_for_author: %w[view edit_info],
      budget_investment_created: %w[view edit_info],
      budget_investment_selected: %w[view edit_info],
      budget_investment_unfeasible: %w[view edit_info],
      budget_investment_not_selected: %w[view edit_info],
      budget_investment_unselected: %w[view edit_info],
      budget_investment_takecharge: %w[view edit_info],
      budget_investment_next_year_budget: %w[view edit_info],
      comment: %w[view edit_info],
      reply: %w[view edit_info],
      direct_message_for_receiver: %w[view edit_info],
      direct_message_for_sender: %w[view edit_info],
      email_verification: %w[view edit_info],
      user_invite: %w[view edit_info],
      evaluation_comment: %w[view edit_info],
      management_newsletter: %w[view edit_info]
    }
  end

  def view
    case @system_email
    when "proposal_notification_digest"
      load_sample_proposal_notifications
    when "duplicated_proposal_for_author"
      load_sample_duplicated_proposal
    when /\Abudget_investment/
      load_sample_investment
    when /\Adirect_message/
      load_sample_direct_message
    when "comment"
      load_sample_comment
    when "reply"
      load_sample_reply
    when "email_verification"
      load_sample_user
    when "user_invite"
      @subject = t("mailers.user_invite.subject", org_name: Setting["org_name"])
    when "evaluation_comment"
      load_sample_valuation_comment
    when "management_newsletter"
      load_sample_management_newsletter
    end
  end

  private

    def load_sample_duplicated_proposal
      @subject = t("mailers.duplicated_proposal_for_author.subject",
                   proposal_title: t("mailers.duplicated_proposal_for_author.sample.proposal.title"))
      @proposal = Proposal.new(title: t("mailers.duplicated_proposal_for_author.sample.proposal.title"),
                               description: t("mailers.duplicated_proposal_for_author
                                                .sample.proposal.description"))
      @original_proposal = Proposal.new(title: t("mailers.duplicated_proposal_for_author
                                                  .sample.original_proposal.title"),
                                        description: t("mailers.duplicated_proposal_for_author
                                                        .sample.original_proposal.description"))
    end

    def load_sample_management_newsletter
      @subject = "#{t("admin.system_emails.management_newsletter.mailer.subject")} #{Time.zone.now.to_date}"
      most_supported_proposals = Proposal.sort_by_confidence_score.limit(3)
      active_debates = Debate.sort_by_supports.limit(3)
      preview_processes = Legislation::Process.published.active.preview_phase.order(start_date: :asc).limit(3)
      public_processes = Legislation::Process.published.active.public_phase.order(start_date: :asc).limit(3)
      @management_newsletter = ManagementNewsletter.new(status: "pending")

      @management_newsletter
        .most_supported_proposals << most_supported_proposals if most_supported_proposals.present?
      @management_newsletter.active_debates << active_debates if active_debates.present?
      @management_newsletter.preview_processes << preview_processes if preview_processes.present?
      @management_newsletter.public_processes << public_processes if public_processes.present?
    end
end
