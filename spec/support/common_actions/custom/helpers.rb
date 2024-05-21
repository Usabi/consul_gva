# frozen_string_literal: true

module Helpers
  def select_language(lang)
    within(".radio-toolbar") do
      find("label[for=local-#{lang}]").click
    end
  end
end
