load Rails.root.join("app", "models", "i18n_content.rb")

class I18nContent
  # Keys defined only in some locale files (custom/es, custom/val) must be listed
  # explicitly, otherwise they would be missing when the admin locale lacks them.
  FOOTER_TRANSLATIONS = %w[
    application.slogan_text.footer
    layouts.footer.citizen_opinions
    layouts.footer.contact_us_short
    layouts.footer.government
  ].freeze

  class << self
    alias_method :consul_translations_for, :translations_for

    def translations_for(tab)
      if tab.to_s == "footer"
        footer_translations
      else
        consul_translations_for(tab)
      end
    end

    def footer_translations
      (FOOTER_TRANSLATIONS + consul_translations_for(:layouts).grep(/\Alayouts\.footer\./)).uniq
    end
  end
end
