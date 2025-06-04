module Custom::AdminHelper
  def menu_budgets?
    controller_name.starts_with?("budget") && controller_name != "budget_managers"
  end

  def menu_profiles?
    %w[administrators organizations officials moderators valuators managers users legislators budget_managers].include?(controller_name)
  end

  def link_to_sorted_admin_resource(resource_name, column)
    direction = set_direction(params[:direction])
    icon = set_sorting_icon(direction, column)

    translation = t("admin.#{resource_name}.index.list.#{column}")
    controller = resource_name == "polls" ? resource_name : "admin/#{resource_name}"
    link_to(
      safe_join([translation, tag.span(class: "icon-sortable #{icon}")]),
      url_for(controller: controller, action: "index", sort_by: column, direction: direction)
    )
  end
  def set_sorting_icon(direction, sort_by)
    if sort_by.to_s == params[:sort_by]
      direction == "desc" ? "desc" : "asc"
    else
      ""
    end
  end

  def admin_tags_select_options(resoures, context)
    resoures.tags_on(context).order(:name).pluck(:name)
  end

  def admin_goal_options(selected_code = nil)
    options_from_collection_for_select(SDG::Goal.order(:code), :code, :code_and_title, selected_code)
  end

  def admin_target_options(selected_code = nil)
    targets = SDG::Target.all + SDG::LocalTarget.all

    options_from_collection_for_select(targets.sort, :code, :code_and_title, selected_code)
  end

  def date_range_options
    options_for_select(
      [
        [t("shared.advanced_search.date_1"), 1],
        [t("shared.advanced_search.date_2"), 2],
        [t("shared.advanced_search.date_3"), 3],
        [t("shared.advanced_search.date_4"), 4],
        [t("shared.advanced_search.date_5"), "custom"]
      ],
      selected_date_range
    )
  end

  def selected_date_range
    custom_date_range? ? "custom" : advanced_search[:date_min]
  end

  def custom_date_range?
    advanced_search[:date_max].present?
  end

  def advanced_search
    params[:advanced_search] || {}
  end

end
