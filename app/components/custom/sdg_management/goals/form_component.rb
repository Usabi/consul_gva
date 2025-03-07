class SDGManagement::Goals::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  use_helpers :site_customization_enable_translation?
  attr_reader :goal, :contents

  def initialize(goal)
    @goal = goal
    @contents = [goal.content]
  end

  private

    def translation_enabled_tag(locale, enabled)
      hidden_field_tag("enabled_translations[#{locale}]", (enabled ? 1 : 0))
    end

    def enabled_locales
      Setting.enabled_locales
    end
end
