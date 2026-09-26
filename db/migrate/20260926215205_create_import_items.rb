class CreateImportItems < ActiveRecord::Migration[8.1]
  def change
    create_table :import_items do |t|
      t.references :import, null: false, foreign_key: true
      t.string :label
      t.boolean :processed

      t.timestamps
    end
  end
end
