class Admin::Budgets::HelpPageComponent < ApplicationComponent
  include Header
  attr_reader :budgets

  def initialize(help_text_content)
    @help_text_content = help_text_content
  end

  def title
    t("admin.budgets.index.title")
  end
end
