class Game < ApplicationRecord
  belongs_to :user
  belongs_to :quest
  has_one :report 
end
