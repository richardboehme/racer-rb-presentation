class Participation < ApplicationRecord
  belongs_to :meeting
  belongs_to :participant

  validates :meeting, presence: true
  validates :participant, presence: true
  validates :participant_id, uniqueness: { scope: :meeting_id, message: "already registered for this meeting" }
end
