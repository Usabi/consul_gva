class AddPositionToDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :position, :integer
  end
end
