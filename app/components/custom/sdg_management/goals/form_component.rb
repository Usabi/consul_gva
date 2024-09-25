class SDGManagement::Goals::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  use_helpers :site_customization_enable_translation?
  attr_reader :goal, :contents

  def initialize(goal)
    @goal = goal
    @contents = [goal.content]
  end
end
