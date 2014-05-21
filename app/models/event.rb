class Event < ActiveRecord::Base
    belongs_to :club

    validates :name, presence: :true
    validates :description, presence: :true
end
