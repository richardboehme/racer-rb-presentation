alice   = participants.create :alice,   name: "Alice Müller",   email: "alice@example.com"
bob     = participants.create :bob,     name: "Bob Schmidt",    email: "bob@example.com"
charlie = participants.create :charlie, name: "Charlie Weber",   email: "charlie@example.com"
diana   = participants.create :diana,   name: "Diana Fischer",  email: "diana@example.com"

dresdenrb_jan = meetings.create :dresdenrb_jan,
  title: "Dresden.rb — January Meetup",
  held_on: Date.new(2026, 1, 8)

dresdenrb_feb = meetings.create :dresdenrb_feb,
  title: "Dresden.rb — February Meetup",
  held_on: Date.new(2026, 2, 5)

dresdenrb_mar = meetings.create :dresdenrb_mar,
  title: "Dresden.rb — March Meetup",
  held_on: Date.new(2026, 3, 4)

participations.create meeting: dresdenrb_jan, participant: alice
participations.create meeting: dresdenrb_jan, participant: bob
participations.create meeting: dresdenrb_jan, participant: charlie

participations.create meeting: dresdenrb_feb, participant: alice
participations.create meeting: dresdenrb_feb, participant: diana

participations.create meeting: dresdenrb_mar, participant: bob
participations.create meeting: dresdenrb_mar, participant: charlie
participations.create meeting: dresdenrb_mar, participant: diana
