class Report < ApplicationRecord
  belongs_to :game, dependent: :destroy
end
