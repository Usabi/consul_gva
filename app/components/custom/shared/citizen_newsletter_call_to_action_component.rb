class Shared::CitizenNewsletterCallToActionComponent < ApplicationComponent
  def render?
    Setting["feature.citizen_newsletter"].present?
  end

  def link_path
    if helpers.user_signed_in?
      helpers.account_path(anchor: "citizen_newsletter")
    else
      helpers.new_user_session_path
    end
  end

  def link_text
    if helpers.user_signed_in?
      t("citizen_newsletter.call_to_action.signed_in")
    else
      t("citizen_newsletter.call_to_action.guest")
    end
  end
end
