class CreateLicenses < ActiveRecord::Migration[8.1]
  def change
    create_table :licenses do |t|
      t.string :identifier
      t.datetime :expires_at
      t.datetime :revoked_at

      t.timestamps
    end
  end
end
