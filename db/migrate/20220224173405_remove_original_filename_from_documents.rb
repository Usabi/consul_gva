class RemoveOriginalFilenameFromDocuments < ActiveRecord::Migration[5.1]
  def change
    remove_column :documents, :original_filename if column_exists?(:documents, :original_filename)
  end
end
