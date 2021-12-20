class Room < ApplicationRecord
  belongs_to :game
  validates :encounter, presence: true
  validates :visited, inclusion: {in: [true, false] }
end