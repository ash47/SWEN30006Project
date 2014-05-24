class Event < ActiveRecord::Base
    belongs_to :club

    validates :name, presence: :true
    validates :description, presence: :true

    # The details stage for creating an event
    def self.stage_details
        'details'
    end

    # The tickets stage for creating an event
    def self.stage_tickets
        'tickets'
    end

    # The confirm stage for creating an event
    def self.stage_confirm
        'confirm'
    end
end
