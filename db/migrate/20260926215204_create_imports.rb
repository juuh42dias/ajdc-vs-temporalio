class CreateImports < ActiveRecord::Migration[8.1]
  def change
    create_table :imports do |t|
      t.string :name
      t.boolean :confirmed
      t.string :status

      t.timestamps
    end
  end
end
