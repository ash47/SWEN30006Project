class User < ActiveRecord::Base
  has_many :memberships
  has_many :clubs, through: :memberships
  #has_many :admin_clubs, through: :memberships, source: 'clubs', conditions: {'memberships.rank' => 3}
  has_many :messages
  has_many :ticket_reservations

  has_many :unconfirmed_networks, through: :clubs, source: 'club_networks', conditions: {'memberships.rank' => 3, 'club_networks.verified' => false}

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  :admin

  validates :first_name, presence: :true
  validates :last_name, presence: :true
  validates :email, presence: :true,
  							uniqueness: true,
  							format: {
  								with: /\A^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$\z/, # \A and \z are "safe" anchors
  								message: "must must be a valid email address"
  							}
  def full_name
  	return first_name + " " + last_name
  end

  def self.ranks
    {"admin" => 3, "member" => 1}
  end

  # Admin rank on clubs
  def self.rank_admin
    ranks["admin"]
  end

  # User rank on clubs
  def self.rank_member
    ranks["member"]
  end
end
