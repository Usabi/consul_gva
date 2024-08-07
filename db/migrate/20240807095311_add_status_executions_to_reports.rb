class AddStatusExecutionsToReports < ActiveRecord::Migration[6.1]
  def change
    add_column :reports, :status_executions, :boolean

  end
end
