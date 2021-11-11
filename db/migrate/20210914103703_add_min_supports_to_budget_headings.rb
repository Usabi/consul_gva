
class AddMinSupportsToBudgetHeadings < ActiveRecord::Migration[5.1]
  def change
    add_column :budget_headings, :min_supports, :integer, null: true
  end
end
