class Quest < ApplicationRecord
    has_many :games, dependent: :destroy
end
