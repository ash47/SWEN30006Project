class AddRankToClubsUsers < ActiveRecord::Migration
  def change
    add_column :clubs_users, :rank, :integer, :default => 0
  end
end
