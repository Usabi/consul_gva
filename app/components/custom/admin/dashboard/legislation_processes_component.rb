class Admin::Dashboard::LegislationProcessesComponent < ApplicationComponent
  def initialize(preview_processes:, public_processes:)
    @preview_processes = preview_processes
    @public_processes = public_processes
  end
end
