class Ticket < ActiveRecord::Base
  belongs_to :event

  def self.max_tickets
    4
  end
end
