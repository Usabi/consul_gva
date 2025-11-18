class CitizenNewsletterUnsubscriptionsController < ApplicationController
  skip_authorization_check
  before_action :find_user_by_token, only: [:show, :update]

  def show; end

  def update
    if @user.present?
      unsubscribe_from_newsletters
      redirect_to root_path, notice: t("citizen_newsletter.unsubscribe.success")
    else
      redirect_to root_path, alert: t("citizen_newsletter.unsubscribe.invalid_token")
    end
  end

  private

    def find_user_by_token
      @user = User.find_by(subscriptions_token: params[:token])
      redirect_to root_path, alert: t("citizen_newsletter.unsubscribe.invalid_token") unless @user
    end

    def unsubscribe_from_newsletters
      @user.update(
        newsletter_debates: false,
        newsletter_proposals: false,
        newsletter_legislation: false
      )
    end
end
