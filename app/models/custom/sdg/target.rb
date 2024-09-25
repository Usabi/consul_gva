require_dependency Rails.root.join("app", "models", "sdg", "target").to_s

class SDG::Target
  include ActionView::Helpers::TranslationHelper

  def title
    t("#{i18n_key}.short_title", default: long_title, fallback: nil)
  end

  def long_title
    t("#{i18n_key}.long_title")
  end

  def self.[](code)
    find_by!(code: code)
  end

  def i18n_key_translations
    [
      "#{i18n_key}.short_title",
      "#{i18n_key}.long_title"
    ]
  end

  def content
    i18n_key_translations.map do |string|
      I18nContent.find_or_initialize_by(key: string)
    end
  end
end
