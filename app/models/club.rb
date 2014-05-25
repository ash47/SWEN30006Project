class Club < ActiveRecord::Base
	has_many :memberships
    has_many :users, through: :memberships
    has_many :admins, through: :memberships, source: :user, conditions: {'memberships.rank' => User.rank_admin}
    has_many :events

    has_many :club_networks
    has_many :networks, through: :club_networks, conditions: {'club_networks.verified' => true}
    #has_many :networked_clubs, through: :networks, source: :club

    validates :uni_registration_id, presence: :true
end
