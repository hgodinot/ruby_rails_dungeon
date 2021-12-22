ActiveRecord::Schema.define(version: 2021_12_11_093849) do

  create_table "games", force: :cascade do |t|
    t.integer "user_id", null: false
    t.boolean "over"
    t.boolean "start"
    t.string "choice"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_games_on_user_id"
  end

  create_table "heros", force: :cascade do |t|
    t.boolean "alive"
    t.integer "health"
    t.integer "strength"
    t.integer "defense"
    t.integer "experience"
    t.integer "room_number"
    t.integer "game_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_heros_on_game_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "body"
    t.integer "game_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_messages_on_game_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "encounter"
    t.boolean "visited"
    t.integer "game_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_rooms_on_game_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "games", "users"
  add_foreign_key "heros", "games"
  add_foreign_key "messages", "games"
  add_foreign_key "rooms", "games"
end
