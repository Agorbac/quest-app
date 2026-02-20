class User < ApplicationRecord
  has_one :user_info, dependent: :destroy
  has_many :games, dependent: :destroy
  has_secure_password
  validates :name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  
  def full_name
    "#{name} #{last_name}"
  end
end