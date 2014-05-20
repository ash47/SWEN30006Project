class User < ActiveRecord::Base
  has_and_belongs_to_many :clubs

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

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

end
