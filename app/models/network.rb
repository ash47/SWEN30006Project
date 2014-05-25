class Network < ActiveRecord::Base
  has_many :club_networks
  has_many :clubs, through: :club_networks
  has_many :memberships, through: :clubs
  has_many :admins, through: :memberships, source: :user, conditions: {"memberships.rank" => User.rank_admin}
end
