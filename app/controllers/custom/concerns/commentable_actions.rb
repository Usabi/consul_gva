require_dependency Rails.root.join("app", "controllers", "concerns", "commentable_actions").to_s

module CommentableActions

  def index
    @resources = resource_model.all

    @resources = @current_order == "recommendations" && current_user.present? ? @resources.recommendations(current_user) : @resources.for_render

    if @search_terms.present?
      if @search_terms.to_i.positive?
        @advanced_search_terms ||= ActionController::Parameters.new
        @advanced_search_terms[:id] = @search_terms
      else
        @resources = @resources.search(@search_terms)
      end
    end

    @resources = @advanced_search_terms.present? ? @resources.filter(@advanced_search_terms) : @resources

    @resources = @resources.page(params[:page]).send("sort_by_#{@current_order}")

    index_customization

    @tag_cloud = tag_cloud
    @banners = Banner.in_section(section(resource_model.name)).with_active

    set_resource_votes(@resources)

    set_resources_instance
    @remote_translations = detect_remote_translations(@resources, featured_proposals)
  end


end
