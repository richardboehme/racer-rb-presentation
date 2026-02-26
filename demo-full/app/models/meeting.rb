class Meeting < ApplicationRecord
  has_many :participations, dependent: :destroy
  has_many :participants, through: :participations

  validates :title, presence: true
  validates :held_on, presence: true
end
