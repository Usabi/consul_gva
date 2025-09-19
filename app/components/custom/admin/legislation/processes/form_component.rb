class Admin::Legislation::Processes::FormComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "admin", "legislation", "processes", "form_component.rb")

class Admin::Legislation::Processes::FormComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  attr_reader :process, :councils
  use_helpers :admin_submit_action

  def initialize(process, councils: [])
    @process = process
    @councils = councils
  end
end
