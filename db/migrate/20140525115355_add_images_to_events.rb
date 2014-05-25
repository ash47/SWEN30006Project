class AddImagesToEvents < ActiveRecord::Migration
  def change
    add_column :events, :imagea, :string
    add_column :events, :imageb, :string
    add_column :events, :imagec, :string
  end
end
