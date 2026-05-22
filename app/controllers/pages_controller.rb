class PagesController < ApplicationController
  include FeatureFlags
  skip_authorization_check

  feature_flag :help_page, if: lambda { params[:id] == "help/index" }

  def show
    @custom_page = SiteCustomization::Page.published.find_by(slug: params[:id])

    if @custom_page.present?
      @cards = @custom_page.cards.sort_by_order
      render action: :custom_page
    else
      page_action = params[:id].split(".").first.to_s
      raise ActionView::MissingTemplate.new([], page_action, [], false, {}) unless page_action.match?(/\A[\w\/\-]+\z/)
      render action: page_action
    end
  rescue ActionView::MissingTemplate
    head :not_found, content_type: "text/html"
  end
end
