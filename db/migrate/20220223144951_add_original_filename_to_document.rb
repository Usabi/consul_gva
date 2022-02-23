class AddOriginalFilenameToDocument < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :original_filename, :string
  end
end
