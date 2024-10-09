class SDGManagement::Targets::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  use_helpers :site_customization_enable_translation?
  attr_reader :target, :contents

  def initialize(target)
    @target = target
    @contents = [target.content]
  end
end
