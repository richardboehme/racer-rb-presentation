require "application_system_test_case"

class ParticipantsTest < ApplicationSystemTestCase
  test "participants index lists all participants alphabetically" do
    visit participants_url

    names = all("li").map(&:text)
    name_only = names.map { |t| t.split("(").first.strip }
    assert_equal name_only, name_only.sort
  end

  test "participants index shows meeting counts" do
    visit participants_url

    within("li", text: "Alice Müller") { assert_text "2 meetings" }
    within("li", text: "Bob Schmidt")  { assert_text "2 meetings" }
  end

  test "clicking a participant navigates to their detail page" do
    visit participants_url
    click_on "Alice Müller"

    assert_current_path participant_path(participants.alice)
    assert_text "Alice Müller"
  end

  test "participant detail page shows their email" do
    visit participant_url(participants.alice)

    assert_text "alice@example.com"
  end

  test "participant detail page lists attended meetups" do
    visit participant_url(participants.alice)

    assert_text "Dresden.rb — January Meetup"
    assert_text "Dresden.rb — February Meetup"
  end

  test "participant detail page does not list unattended meetups" do
    visit participant_url(participants.alice)

    assert_no_text "Dresden.rb — March Meetup"
  end

  test "participant detail page shows meeting count" do
    visit participant_url(participants.alice)

    assert_text "Meetings attended (2)"
  end

  test "clicking a meeting on participant page navigates to meeting detail" do
    visit participant_url(participants.bob)
    click_on "Dresden.rb — January Meetup"

    assert_current_path meeting_path(meetings.dresdenrb_jan)
  end

  test "back link on participant detail page returns to participants index" do
    visit participant_url(participants.alice)
    click_on "All participants"

    assert_current_path participants_path
  end
end
