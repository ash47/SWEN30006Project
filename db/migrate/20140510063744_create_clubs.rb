class CreateClubs < ActiveRecord::Migration
  def change
    create_table :clubs do |t|
      t.string :name
      t.text :description
      t.string :website
      t.integer :uni_registration_id
      t.boolean :is_confirmed

      t.timestamps
    end
    add_index :clubs, :uni_registration_id, unique: true
  end
end
