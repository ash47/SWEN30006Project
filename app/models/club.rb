class Club < ActiveRecord::Base
	has_many :memberships
    has_many :users, through: :memberships

    validates :uni_registration_id, presence: :true
end
