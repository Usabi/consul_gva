class AddCouncilToLegislationProcess < ActiveRecord::Migration[6.1]
  def change
    add_column :legislation_processes, :council_id, :integer
    add_index :legislation_processes, :council_id
    add_foreign_key :legislation_processes, :legislation_councils, column: :council_id
  end
end
