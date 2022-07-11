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

ActiveRecord::Schema[7.0].define(version: 2022_07_11_214444) do
  create_table "applications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.binary "token", limit: 16
    t.string "name", null: false
    t.bigint "chats_count", default: 0, null: false
    t.datetime "updated_at"
    t.virtual "created_at", type: :datetime, precision: nil, as: "from_unixtime((conv(hex((`token` >> 80)),16,10) / 1000.0))"
    t.index ["token"], name: "unique_token_idx", unique: true
  end

  create_table "chats", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "number", null: false
    t.bigint "messages_count", default: 0, null: false
    t.bigint "app_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_id"], name: "app_id_idx"
  end

  create_table "messages", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "chat_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "chat_id_idx"
  end

  add_foreign_key "chats", "applications", column: "app_id", name: "chat_to_application_fk"
  add_foreign_key "messages", "chats", name: "message_to_chat_fk"
end
