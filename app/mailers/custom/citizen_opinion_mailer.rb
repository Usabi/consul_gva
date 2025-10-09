class CitizenOpinionMailer < ApplicationMailer
  NOTIFICATION_RECIPIENT = Rails.application.secrets.citizen_opinions_mail_recipient

  def notification(citizen_opinion)
    @citizen_opinion = citizen_opinion
    mail(to: NOTIFICATION_RECIPIENT,
         subject: t("citizen_opinion_mailer.notification.subject",
                    topic: t("citizen_opinions.form.topic.options.#{citizen_opinion.topic}")))
  end

  def confirmation(citizen_opinion)
    @citizen_opinion = citizen_opinion
    mail(to: citizen_opinion.email,
         subject: t("citizen_opinion_mailer.confirmation.subject"))
  end
end
