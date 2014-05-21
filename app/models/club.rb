class Club < ActiveRecord::Base
	has_and_belongs_to_many :users

    validates :uni_registration_id, presence: :true
end
