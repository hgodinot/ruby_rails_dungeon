class Hero < ApplicationRecord
  belongs_to :game

  validates :alive,       inclusion: { in: [true, false] }
  validates :health,      presence: true
  validates :strength,    presence: true
  validates :defense,     presence: true
  validates :experience,  presence: true
  validates :room_number, presence: true
end