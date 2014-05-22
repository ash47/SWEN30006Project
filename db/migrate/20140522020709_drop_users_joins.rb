class DropUsersJoins < ActiveRecord::Migration
  def change
    drop_table :clubs_users
  end
end
