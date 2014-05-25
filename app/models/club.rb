class Club < ActiveRecord::Base
	has_many :memberships
    has_many :users, through: :memberships
    has_many :admins, through: :memberships, source: :user, conditions: {"memberships.rank" => User.rank_admin}
    has_many :events

    validates :uni_registration_id, presence: :true
end
