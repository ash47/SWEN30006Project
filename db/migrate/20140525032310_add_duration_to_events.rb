class AddDurationToEvents < ActiveRecord::Migration
  def change
    add_column :events, :duration, :integer
    add_column :events, :start_time, :DateTime
    add_column :events, :club_id, :integer
    add_column :memberships, :title, :string, default: ''
  end
end
