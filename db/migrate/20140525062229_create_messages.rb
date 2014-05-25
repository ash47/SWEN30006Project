class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.belongs_to :user
      t.string :message
      t.boolean :read, :default => false

      t.timestamps
    end
  end
end
