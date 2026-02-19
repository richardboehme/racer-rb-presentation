require "test_helper"

class MeetingTest < ActiveSupport::TestCase
  # Validations

  test "is valid with title and held_on" do
    meeting = Meeting.new(title: "Dresden.rb — April Meetup", held_on: Date.today)
    assert meeting.valid?
  end

  test "is invalid without a title" do
    meeting = Meeting.new(held_on: Date.today)
    assert_not meeting.valid?
    assert_includes meeting.errors[:title], "can't be blank"
  end

  test "is invalid without held_on" do
    meeting = Meeting.new(title: "Dresden.rb — April Meetup")
    assert_not meeting.valid?
    assert_includes meeting.errors[:held_on], "can't be blank"
  end

  # Associations via seed data

  test "january meetup has three participants" do
    assert_equal 3, meetings.dresdenrb_jan.participants.count
  end

  test "february meetup has two participants" do
    assert_equal 2, meetings.dresdenrb_feb.participants.count
  end

  test "march meetup has three participants" do
    assert_equal 3, meetings.dresdenrb_mar.participants.count
  end

  test "january meetup includes alice" do
    assert_includes meetings.dresdenrb_jan.participants, participants.alice
  end

  test "january meetup does not include diana" do
    assert_not_includes meetings.dresdenrb_jan.participants, participants.diana
  end

  test "participants are reachable through through association" do
    names = meetings.dresdenrb_jan.participants.pluck(:name)
    assert_includes names, "Alice Müller"
    assert_includes names, "Bob Schmidt"
    assert_includes names, "Charlie Weber"
  end

  # Dependent destroy

  test "destroying a meeting also destroys its participations" do
    meeting = meetings.dresdenrb_jan
    participation_ids = meeting.participations.pluck(:id)

    meeting.destroy!

    participation_ids.each do |id|
      assert_not Participation.exists?(id)
    end
  end

  test "destroying a meeting does not destroy the participants themselves" do
    meeting = meetings.dresdenrb_jan
    participant_ids = meeting.participants.pluck(:id)

    meeting.destroy!

    participant_ids.each do |id|
      assert Participant.exists?(id)
    end
  end
end
