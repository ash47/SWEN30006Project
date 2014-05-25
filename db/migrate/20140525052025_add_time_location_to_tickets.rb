class AddTimeLocationToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :pickup, :string
    add_column :tickets, :opendate, :date
    add_column :tickets, :closedate, :date

    add_column :events, :visibledate, :date
  end
end
