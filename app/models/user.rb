class User < ApplicationRecord

  has_many :games, dependent: :destroy
  has_many :actor_schedules, dependent: :destroy
  has_many :actor_transactions, dependent: :destroy

  has_secure_password
  validates :name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  enum :role, { player: 0, actor: 1, admin: 2 }
  
  def full_name
    "#{name} #{last_name}"
  end
end