class AddKindToMilestoneStatus < ActiveRecord::Migration[6.1]
  def change
    add_column :milestone_statuses, :kind, :string
  end
end
