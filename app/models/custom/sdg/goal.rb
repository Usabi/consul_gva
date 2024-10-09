require_dependency Rails.root.join("app", "models", "sdg", "goal").to_s

class SDG::Goal
  include ActionView::Helpers::TranslationHelper

  def title
    t("sdg.goals.goal_#{code}.title")
  end
  alias_method :long_title, :title

  def title_in_two_lines
    t("sdg.goals.goal_#{code}.title_in_two_lines")
  end

  def description
    t("sdg.goals.goal_#{code}.description")
  end

  def long_description
    t("sdg.goals.goal_#{code}.long_description")
  end

  def i18n_key_translations
    [
      "sdg.goals.goal_#{code}.title",
      "sdg.goals.goal_#{code}.title_in_two_lines",
      "sdg.goals.goal_#{code}.description",
      "sdg.goals.goal_#{code}.long_description"
    ]
  end

  def content
    i18n_key_translations.map do |string|
      I18nContent.find_or_initialize_by(key: string)
    end
  end
end
