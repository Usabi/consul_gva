module Admin::HelpPagesActions
  extend ActiveSupport::Concern

  def help_element(section)
    ::SiteCustomization::HelpText.find_by(section: section)
  end

  def help_text(section)
    @help_text_content = help_element(section).content
  end
end
