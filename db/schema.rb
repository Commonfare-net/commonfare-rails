# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190429091329) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.text "body"
    t.bigint "commoner_id"
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "anonymous", default: false
    t.index ["anonymous"], name: "index_comments_on_anonymous"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["commoner_id"], name: "index_comments_on_commoner_id"
  end

  create_table "commoners", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "avatar"
    t.text "description"
    t.jsonb "commonshare_data"
  end

  create_table "commoners_tags", id: false, force: :cascade do |t|
    t.bigint "commoner_id", null: false
    t.bigint "tag_id", null: false
    t.index ["commoner_id", "tag_id"], name: "index_commoners_tags_on_commoner_id_and_tag_id", unique: true
    t.index ["tag_id", "commoner_id"], name: "index_commoners_tags_on_tag_id_and_commoner_id", unique: true
  end

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sender_id"
    t.bigint "recipient_id"
    t.index ["recipient_id"], name: "index_conversations_on_recipient_id"
    t.index ["sender_id"], name: "index_conversations_on_sender_id"
  end

  create_table "currencies", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "endpoint"
    t.bigint "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "api_key"
    t.index ["group_id"], name: "index_currencies_on_group_id"
  end

  create_table "discussions", force: :cascade do |t|
    t.bigint "group_id"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_discussions_on_group_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.string "locale"
    t.index ["locale"], name: "index_friendly_id_slugs_on_locale"
    t.index ["slug", "sluggable_type", "locale"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_locale"
    t.index ["slug", "sluggable_type", "scope", "locale"], name: "index_friendly_id_slugs_uniqueness", unique: true
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "avatar"
  end

  create_table "images", force: :cascade do |t|
    t.string "picture"
    t.bigint "commoner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "imageable_id"
    t.string "imageable_type"
    t.index ["commoner_id"], name: "index_images_on_commoner_id"
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id"
  end

  create_table "join_requests", force: :cascade do |t|
    t.bigint "group_id"
    t.bigint "commoner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "aasm_state"
    t.index ["commoner_id"], name: "index_join_requests_on_commoner_id"
    t.index ["group_id"], name: "index_join_requests_on_group_id"
  end

  create_table "listings", force: :cascade do |t|
    t.bigint "commoner_id"
    t.string "title"
    t.text "description"
    t.string "place"
    t.decimal "min_price", precision: 18, scale: 6
    t.decimal "max_price", precision: 18, scale: 6
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.float "latitude"
    t.float "longitude"
    t.index ["commoner_id"], name: "index_listings_on_commoner_id"
    t.index ["slug"], name: "index_listings_on_slug", unique: true
  end

  create_table "listings_tags", id: false, force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "tag_id", null: false
    t.index ["listing_id", "tag_id"], name: "index_listings_tags_on_listing_id_and_tag_id", unique: true
    t.index ["tag_id", "listing_id"], name: "index_listings_tags_on_tag_id_and_listing_id", unique: true
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "group_id"
    t.bigint "commoner_id"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commoner_id"], name: "index_memberships_on_commoner_id"
    t.index ["group_id"], name: "index_memberships_on_group_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "commoner_id"
    t.string "body"
    t.string "messageable_type"
    t.bigint "messageable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "read", default: false
    t.index ["commoner_id"], name: "index_messages_on_commoner_id"
    t.index ["messageable_type", "messageable_id"], name: "index_messages_on_messageable_type_and_messageable_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "target_type", null: false
    t.bigint "target_id", null: false
    t.string "notifiable_type", null: false
    t.bigint "notifiable_id", null: false
    t.string "key", null: false
    t.string "group_type"
    t.bigint "group_id"
    t.integer "group_owner_id"
    t.string "notifier_type"
    t.bigint "notifier_id"
    t.text "parameters"
    t.datetime "opened_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_owner_id"], name: "index_notifications_on_group_owner_id"
    t.index ["group_type", "group_id"], name: "index_notifications_on_group_type_and_group_id"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["notifier_type", "notifier_id"], name: "index_notifications_on_notifier_type_and_notifier_id"
    t.index ["target_type", "target_id"], name: "index_notifications_on_target_type_and_target_id"
  end

  create_table "stories", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.string "place"
    t.bigint "commoner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.boolean "welfare_provision", default: false
    t.boolean "good_practice", default: false
    t.boolean "anonymous", default: false
    t.jsonb "content_json"
    t.boolean "created_with_story_builder", default: false
    t.boolean "published", default: false
    t.string "title_draft"
    t.text "content_draft"
    t.jsonb "content_json_draft"
    t.string "place_draft"
    t.bigint "group_id"
    t.jsonb "template_json"
    t.boolean "tutorial", default: false
    t.boolean "was_good_practice", default: false
    t.index ["anonymous"], name: "index_stories_on_anonymous"
    t.index ["commoner_id"], name: "index_stories_on_commoner_id"
    t.index ["good_practice"], name: "index_stories_on_good_practice"
    t.index ["group_id"], name: "index_stories_on_group_id"
    t.index ["slug"], name: "index_stories_on_slug", unique: true
    t.index ["tutorial"], name: "index_stories_on_tutorial"
    t.index ["was_good_practice"], name: "index_stories_on_was_good_practice"
    t.index ["welfare_provision"], name: "index_stories_on_welfare_provision"
  end

  create_table "stories_tags", id: false, force: :cascade do |t|
    t.bigint "story_id", null: false
    t.bigint "tag_id", null: false
    t.index ["story_id", "tag_id"], name: "index_stories_tags_on_story_id_and_tag_id", unique: true
    t.index ["tag_id", "story_id"], name: "index_stories_tags_on_tag_id_and_story_id", unique: true
  end

  create_table "story_translations", force: :cascade do |t|
    t.integer "story_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "content"
    t.string "slug"
    t.jsonb "content_json"
    t.string "title_draft"
    t.text "content_draft"
    t.jsonb "content_json_draft"
    t.index ["locale"], name: "index_story_translations_on_locale"
    t.index ["story_id"], name: "index_story_translations_on_story_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "target_type", null: false
    t.bigint "target_id", null: false
    t.string "key", null: false
    t.boolean "subscribing", default: true, null: false
    t.boolean "subscribing_to_email", default: true, null: false
    t.datetime "subscribed_at"
    t.datetime "unsubscribed_at"
    t.datetime "subscribed_to_email_at"
    t.datetime "unsubscribed_to_email_at"
    t.text "optional_targets"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_subscriptions_on_key"
    t.index ["target_type", "target_id", "key"], name: "index_subscriptions_on_target_type_and_target_id_and_key", unique: true
    t.index ["target_type", "target_id"], name: "index_subscriptions_on_target_type_and_target_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["slug"], name: "index_tags_on_slug", unique: true
  end

  create_table "transactions", force: :cascade do |t|
    t.text "message"
    t.decimal "amount", precision: 18, scale: 6
    t.string "txid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "from_wallet_id"
    t.bigint "to_wallet_id"
    t.index ["from_wallet_id"], name: "index_transactions_on_from_wallet_id"
    t.index ["to_wallet_id"], name: "index_transactions_on_to_wallet_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "meta_id"
    t.string "meta_type"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wallets", force: :cascade do |t|
    t.string "walletable_type"
    t.bigint "walletable_id"
    t.decimal "balance", precision: 18, scale: 6
    t.string "address", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "currency_id"
    t.string "hash_id"
    t.index ["currency_id"], name: "index_wallets_on_currency_id"
    t.index ["hash_id"], name: "index_wallets_on_hash_id", unique: true
    t.index ["walletable_type", "walletable_id"], name: "index_wallets_on_walletable_type_and_walletable_id"
  end

  add_foreign_key "comments", "commoners"
  add_foreign_key "conversations", "commoners", column: "recipient_id"
  add_foreign_key "conversations", "commoners", column: "sender_id"
  add_foreign_key "currencies", "groups"
  add_foreign_key "discussions", "groups"
  add_foreign_key "images", "commoners"
  add_foreign_key "join_requests", "commoners"
  add_foreign_key "join_requests", "groups"
  add_foreign_key "listings", "commoners"
  add_foreign_key "memberships", "commoners"
  add_foreign_key "memberships", "groups"
  add_foreign_key "messages", "commoners"
  add_foreign_key "stories", "commoners"
  add_foreign_key "stories", "groups"
  add_foreign_key "transactions", "wallets", column: "from_wallet_id"
  add_foreign_key "transactions", "wallets", column: "to_wallet_id"
  add_foreign_key "wallets", "currencies"
end
