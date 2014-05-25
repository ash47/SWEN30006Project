class Event < ActiveRecord::Base
    belongs_to :club

    has_many :tickets

    validates :name, presence: :true
    validates :description, presence: :true
    validates :duration, presence: :true
    validates :start_time, presence: :true

    # User wants to create a new event from scratch
    def self.stage_new
        'new'
    end

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

    # This is the stage where we actually create the event
    def self.stage_doit
        'doit'
    end
end
