class Admin::SiteCustomization::HelpTexts::IndexComponent < ApplicationComponent
  include Header
  attr_reader :help_texts

  def initialize(help_texts)
    @help_texts = help_texts
  end

  private

    def title
      t("admin.site_customization.help_texts.index.title")
    end
end