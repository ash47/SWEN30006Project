class CreateClubs < ActiveRecord::Migration
  def change
    create_table :clubs do |t|
      t.string :name, null: false, default: ""
      t.text :description
      t.string :website
      t.integer :uni_registration_id, null: false, default: -1
      t.boolean :is_confirmed, null: false, default: false

      t.timestamps
    end
    add_index :clubs, :uni_registration_id, unique: true
  end
end
