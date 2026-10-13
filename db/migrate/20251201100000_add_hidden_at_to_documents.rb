class AddHiddenAtToDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :hidden_at, :datetime
    add_index :documents, :hidden_at
  end
end
