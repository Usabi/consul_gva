load Rails.root.join("app", "mailers", "mailer.rb")

class Mailer
  def budget_investment_not_selected(investment)
    @investment = investment
    @author = investment.author
    @email_to = @author.email

    with_user(@author) do
      mail(to: @email_to, subject: t("mailers.budget_investment_not_selected.subject",
                                     code: @investment.code))
    end
  end

  def budget_investment_takecharge(investment)
    @investment = investment
    @author = investment.author
    @email_to = @author.email

    with_user(@author) do
      mail(
        to: @email_to,
        subject: t("mailers.budget_investment_takecharge.subject", code: @investment.code)
      )
    end
  end

  def budget_investment_next_year_budget(investment)
    @investment = investment
    @author = investment.author
    @email_to = @author.email

    with_user(@author) do
      mail(
        to: @email_to,
        subject: t("mailers.budget_investment_next_year_budget.subject", code: @investment.code)
      )
    end
  end

  def duplicated_proposal_for_author(author, proposal)
    @proposal = proposal
    @original_proposal = Proposal.find(@proposal.duplicated_of_proposal_id)
    @email_to = author.email

    mail(to: @email_to, subject: t("mailers.duplicated_proposal_for_author.subject",
                                   proposal_title: @proposal.title))
  end

  def management_newsletter(newsletter)
    @management_newsletter = newsletter
    @email_to = User.joins(:administrator).pluck(:email)
    subject = "#{t("admin.management_newsletters.mailer.subject")} #{Time.zone.now.to_date}"
    mail(to: @email_to, subject: subject)
  end

  def citizen_newsletter(newsletter, user)
    @citizen_newsletter = newsletter
    @user = user
    @email_to = user.email
    @token = user.subscriptions_token

    with_user(user) do
      subject = t("citizen_newsletter.email.subject", date: l(Date.current, format: :long))
      mail(to: @email_to, subject: subject)
    end
  end
end
