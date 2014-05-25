class CreateClubNetworks < ActiveRecord::Migration
  def change
    create_table :club_networks do |t|
      t.belongs_to :club
      t.belongs_to :network
      t.boolean :verified, :default => false
    end
  end
end
