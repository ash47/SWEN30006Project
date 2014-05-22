class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.belongs_to  :club
      t.belongs_to  :user
      t.integer :rank,      default: 0

      t.timestamps
    end
  end
end
