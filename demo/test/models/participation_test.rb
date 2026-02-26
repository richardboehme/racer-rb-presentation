require "test_helper"

class ParticipationTest < ActiveSupport::TestCase
  # Validations

  test "is valid with meeting and participant" do
    new_meeting = Meeting.create!(title: "Dresden.rb — April Meetup", held_on: Date.today)
    participation = Participation.new(meeting: new_meeting, participant: participants.alice)
    assert participation.valid?
  end

  test "is invalid without a meeting" do
    participation = Participation.new(participant: participants.alice)
    assert_not participation.valid?
    assert_includes participation.errors[:meeting], "must exist"
  end

  test "is invalid without a participant" do
    participation = Participation.new(meeting: meetings.dresdenrb_jan)
    assert_not participation.valid?
    assert_includes participation.errors[:participant], "must exist"
  end

  test "prevents duplicate registration for the same meeting" do
    duplicate = Participation.new(
      meeting: meetings.dresdenrb_jan,
      participant: participants.alice
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:participant_id], "already registered for this meeting"
  end

  test "allows the same participant to join a different meeting" do
    new_meeting = Meeting.create!(title: "Dresden.rb — April Meetup", held_on: Date.today)
    participation = Participation.new(meeting: new_meeting, participant: participants.alice)
    assert participation.valid?
  end

  test "allows different participants in the same meeting" do
    new_participant = Participant.create!(name: "Eve Braun", email: "eve@example.com")
    participation = Participation.new(meeting: meetings.dresdenrb_jan, participant: new_participant)
    assert participation.valid?
  end

  # Associations

  test "belongs to a meeting" do
    participation = meetings.dresdenrb_jan.participations.first
    assert_instance_of Meeting, participation.meeting
  end

  test "belongs to a participant" do
    participation = meetings.dresdenrb_jan.participations.first
    assert_instance_of Participant, participation.participant
  end

  # Counts

  test "there are eight participations in total" do
    assert_equal 8, Participation.count
  end

  test "january meetup has three participations" do
    assert_equal 3, meetings.dresdenrb_jan.participations.count
  end

  test "february meetup has two participations" do
    assert_equal 2, meetings.dresdenrb_feb.participations.count
  end

  test "march meetup has three participations" do
    assert_equal 3, meetings.dresdenrb_mar.participations.count
  end
end
