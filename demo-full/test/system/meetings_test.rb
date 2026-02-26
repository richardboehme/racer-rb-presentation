require "application_system_test_case"

class MeetingsTest < ApplicationSystemTestCase
  test "meetings index lists all meetups" do
    visit meetings_url

    assert_text "Dresden.rb — January Meetup"
    assert_text "Dresden.rb — February Meetup"
    assert_text "Dresden.rb — March Meetup"
  end

  test "meetings index shows participant counts" do
    visit meetings_url

    within("li", text: "Dresden.rb — January Meetup") { assert_text "3 participants" }
    within("li", text: "Dresden.rb — February Meetup") { assert_text "2 participants" }
    within("li", text: "Dresden.rb — March Meetup") { assert_text "3 participants" }
  end

  test "meetings index shows held_on dates" do
    visit meetings_url

    assert_text "January 8, 2026"
    assert_text "February 5, 2026"
    assert_text "March 4, 2026"
  end

  test "clicking a meeting navigates to its detail page" do
    visit meetings_url
    click_on "Dresden.rb — January Meetup"

    assert_current_path meeting_path(meetings.dresdenrb_jan)
    assert_text "Dresden.rb — January Meetup"
  end

  test "meeting detail page lists its participants" do
    visit meeting_url(meetings.dresdenrb_jan)

    assert_text "Alice Müller"
    assert_text "Bob Schmidt"
    assert_text "Charlie Weber"
  end

  test "meeting detail page does not list non-attendees" do
    visit meeting_url(meetings.dresdenrb_jan)

    assert_no_text "Diana Fischer"
  end

  test "meeting detail page shows participant count" do
    visit meeting_url(meetings.dresdenrb_jan)

    assert_text "Participants (3)"
  end

  test "clicking a participant on the meeting page navigates to their profile" do
    visit meeting_url(meetings.dresdenrb_jan)
    click_on "Alice Müller"

    assert_current_path participant_path(participants.alice)
  end

  test "back link on meeting detail page returns to meetings index" do
    visit meeting_url(meetings.dresdenrb_jan)
    click_on "All meetings"

    assert_current_path meetings_path
  end
end
