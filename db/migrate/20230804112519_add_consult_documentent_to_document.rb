class AddConsultDocumententToDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :consult_document, :boolean, default: false
  end
end
