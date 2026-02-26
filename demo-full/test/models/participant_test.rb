require "test_helper"

class ParticipantTest < ActiveSupport::TestCase
  # Validations

  test "is valid with name and email" do
    participant = Participant.new(name: "Eve Braun", email: "eve@example.com")
    assert participant.valid?
  end

  test "is invalid without a name" do
    participant = Participant.new(email: "eve@example.com")
    assert_not participant.valid?
    assert_includes participant.errors[:name], "can't be blank"
  end

  test "is invalid without an email" do
    participant = Participant.new(name: "Eve Braun")
    assert_not participant.valid?
    assert_includes participant.errors[:email], "can't be blank"
  end

  test "is invalid with a duplicate email" do
    duplicate = Participant.new(name: "Another Alice", email: participants.alice.email)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "allows different participants with different emails" do
    p1 = Participant.new(name: "Eve Braun",  email: "eve@example.com")
    p2 = Participant.new(name: "Frank Bauer", email: "frank@example.com")
    assert p1.valid?
    assert p2.valid?
  end

  # Associations via seed data

  test "alice attended two meetups" do
    assert_equal 2, participants.alice.meetings.count
  end

  test "bob attended two meetups" do
    assert_equal 2, participants.bob.meetings.count
  end

  test "charlie attended two meetups" do
    assert_equal 2, participants.charlie.meetings.count
  end

  test "diana attended two meetups" do
    assert_equal 2, participants.diana.meetings.count
  end

  test "alice attended the january and february meetups" do
    meeting_titles = participants.alice.meetings.pluck(:title)
    assert_includes meeting_titles, "Dresden.rb — January Meetup"
    assert_includes meeting_titles, "Dresden.rb — February Meetup"
  end

  test "alice did not attend the march meetup" do
    assert_not_includes participants.alice.meetings, meetings.dresdenrb_mar
  end

  # Dependent destroy

  test "destroying a participant also destroys their participations" do
    participant = participants.alice
    participation_ids = participant.participations.pluck(:id)

    participant.destroy!

    participation_ids.each do |id|
      assert_not Participation.exists?(id)
    end
  end

  test "destroying a participant does not destroy the meetings" do
    participant = participants.alice
    meeting_ids = participant.meetings.pluck(:id)

    participant.destroy!

    meeting_ids.each do |id|
      assert Meeting.exists?(id)
    end
  end
end
