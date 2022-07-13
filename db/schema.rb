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
    t.index ["token"], name: "unique_token_idx", unique: true
  end

  create_table "chats", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "number", null: false
    t.bigint "messages_count", default: 0, null: false
    t.bigint "application_id", null: false
    t.string "check_sum", null: false
    t.index ["application_id"], name: "app_id_idx"
    t.index ["number", "application_id"], name: "unique_number_per_app_idx", unique: true
  end

  create_table "messages", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "number", null: false
    t.bigint "chat_id", null: false
    t.string "check_sum", null: false
    t.index ["chat_id"], name: "chat_id_idx"
    t.index ["number", "chat_id"], name: "unique_number_per_chat_idx", unique: true
  end

  add_foreign_key "chats", "applications", name: "chat_to_application_fk"
  add_foreign_key "messages", "chats", name: "message_to_chat_fk"
end
