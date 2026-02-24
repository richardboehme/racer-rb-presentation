class Participant < ApplicationRecord
  has_many :participations, dependent: :destroy
  has_many :meetings, through: :participations

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
