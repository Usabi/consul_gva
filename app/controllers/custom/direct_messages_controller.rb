load Rails.root.join("app", "controllers", "direct_messages_controller.rb")

class DirectMessagesController < ApplicationController
  def new
    unless current_user.administrator? || current_user.legislator?
      authorize! :new, @direct_message, message: t("users.direct_messages.new.verified_only",
                                                   verify_account: helpers.link_to_verify_account)
    end
  end
end
