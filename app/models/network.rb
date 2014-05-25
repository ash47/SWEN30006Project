class Network < ActiveRecord::Base
  has_many :club_networks
  has_many :clubs, through: :club_networks, conditions: {"club_networks.verified" => true}
  has_many :u_clubs, through: :club_networks, source: :club, conditions: {"club_networks.verified" => false}
  has_many :memberships, through: :clubs
  has_many :admins, through: :memberships, source: :user, conditions: {"memberships.rank" => User.rank_admin}
  has_many :events, through: :clubs
end
