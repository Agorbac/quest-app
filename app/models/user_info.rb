class UserInfo < ApplicationRecord
  belongs_to :user
  
  validates :info, presence: true, length: { minimum: 10 }
  
end