class Message < ApplicationRecord
  belongs_to :game
  validates :body, presence: true
end
