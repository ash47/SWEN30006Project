class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.belongs_to :event
      t.string :tname
      t.decimal :mprice, :precision => 8, :scale => 2
      t.decimal :nprice, :precision => 8, :scale => 2
      t.decimal :sprice, :precision => 8, :scale => 2
      t.integer :total
      t.integer :remaining
    end
  end
end
