class CreateTicketReservations < ActiveRecord::Migration
  def change
    create_table :ticket_reservations do |t|
      t.belongs_to :user
      t.belongs_to :ticket
      t.belongs_to :event
      t.integer :m_amount
      t.integer :n_amount
      t.integer :s_amount
      t.boolean :pickedup, :default => false

      t.timestamps
    end
  end
end
