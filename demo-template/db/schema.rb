# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_19_162438) do
  create_table "meetings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "held_on"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "participants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "participations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "meeting_id", null: false
    t.integer "participant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["meeting_id"], name: "index_participations_on_meeting_id"
    t.index ["participant_id"], name: "index_participations_on_participant_id"
  end

  add_foreign_key "participations", "meetings"
  add_foreign_key "participations", "participants"
end
