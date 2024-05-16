require "rails_helper"

describe "System Emails" do
  let(:admin) { create(:administrator) }

  before do
    login_as(admin.user)
  end

  context "Index" do
    let(:system_emails_with_preview) { %w[proposal_notification_digest] }
    let(:system_emails) do
      %w[proposal_notification_digest budget_investment_created budget_investment_selected
         budget_investment_unfeasible budget_investment_unselected comment reply
         direct_message_for_receiver direct_message_for_sender email_verification user_invite
         evaluation_comment]
    end

    context "System emails with info" do
      scenario "have information about how to edit the email templates", consul: true do
        visit admin_system_emails_path

        system_emails_with_info = system_emails - system_emails_with_preview
        system_emails_with_info.each do |email_id|
          within("##{email_id}") do
            template_path = email_id == "budget_investment_unfeasible" ? "app/views/custom/mailer/#{email_id}.html.erb" : "app/views/mailer/#{email_id}.html.erb"
            expect(page).to have_content "You can edit this email in"
            expect(page).to have_content template_path

            expect(page).not_to have_link "Preview Pending"
            expect(page).not_to have_button "Send pending"
          end
        end
      end
    end
  end
end
