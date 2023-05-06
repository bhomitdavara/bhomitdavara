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

ActiveRecord::Schema[7.0].define(version: 2023_03_21_065423) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abouts", force: :cascade do |t|
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "blocked_users", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "blocked_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.string "discription"
    t.bigint "post_id", null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: true
    t.integer "status", default: 0
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "complaints", force: :cascade do |t|
    t.bigint "post_id"
    t.bigint "comment_id"
    t.bigint "sub_comment_id"
    t.bigint "user_id", null: false
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_complaints_on_comment_id"
    t.index ["post_id"], name: "index_complaints_on_post_id"
    t.index ["sub_comment_id"], name: "index_complaints_on_sub_comment_id"
    t.index ["user_id"], name: "index_complaints_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_conversations_on_user_id"
  end

  create_table "crop_categories", force: :cascade do |t|
    t.string "name_gu"
    t.string "name_en"
    t.string "name_hi"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crops", force: :cascade do |t|
    t.string "name_gu"
    t.string "name_en"
    t.string "name_hi"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "crop_category_id", null: false
    t.index ["crop_category_id"], name: "index_crops_on_crop_category_id"
  end

  create_table "districts", force: :cascade do |t|
    t.string "name_en"
    t.bigint "state_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name_gu"
    t.string "name_hi"
    t.index ["state_id"], name: "index_districts_on_state_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.string "description"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "fertilizer_items", force: :cascade do |t|
    t.bigint "fertilizer_schedule_id", null: false
    t.string "fertilizer_en"
    t.string "fertilizer_gu"
    t.string "fertilizer_hi"
    t.string "advice_en"
    t.string "advice_gu"
    t.string "advice_hi"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fertilizer_schedule_id"], name: "index_fertilizer_items_on_fertilizer_schedule_id"
  end

  create_table "fertilizer_schedules", force: :cascade do |t|
    t.string "day_duration_en"
    t.string "day_duration_gu"
    t.string "day_duration_hi"
    t.string "date_duration_en"
    t.string "date_duration_gu"
    t.string "date_duration_hi"
    t.string "note_en"
    t.string "note_gu"
    t.string "note_hi"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "crop_id", null: false
    t.integer "priority", default: 0
    t.index ["crop_id"], name: "index_fertilizer_schedules_on_crop_id"
  end

  create_table "likes", force: :cascade do |t|
    t.boolean "liked", default: false
    t.bigint "post_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_likes_on_post_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "maintenances", force: :cascade do |t|
    t.string "devise_tokens"
    t.boolean "status", default: false
    t.string "message"
    t.integer "allowed_users", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.string "content"
    t.string "sender_type", null: false
    t.bigint "sender_id", null: false
    t.integer "conversation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["created_at"], name: "index_messages_on_created_at"
    t.index ["sender_type", "sender_id"], name: "index_messages_on_sender"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.string "type", null: false
    t.jsonb "params"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient"
  end

  create_table "policies", force: :cascade do |t|
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string "discription"
    t.integer "status"
    t.integer "post_type"
    t.integer "tags", default: [], array: true
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_comments", default: 0
    t.integer "total_likes", default: 0
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "problems", force: :cascade do |t|
    t.string "title_en"
    t.string "title_gu"
    t.string "title_hi"
    t.string "description_en"
    t.string "description_gu"
    t.string "description_hi"
    t.integer "tags", default: [], array: true
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "crop_id", null: false
    t.integer "priority", default: 0
    t.index ["crop_id"], name: "index_problems_on_crop_id"
  end

  create_table "product_types", force: :cascade do |t|
    t.string "title_en"
    t.string "title_gu"
    t.string "title_hi"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_uniquenesses", force: :cascade do |t|
    t.string "title_en"
    t.string "title_gu"
    t.string "title_hi"
    t.string "sub_title_en"
    t.string "sub_title_gu"
    t.string "sub_title_hi"
    t.string "description_en"
    t.string "description_gu"
    t.string "description_hi"
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_uniquenesses_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "title_en"
    t.string "title_gu"
    t.string "title_hi"
    t.integer "tags", default: [], array: true
    t.string "other_details_en"
    t.string "other_details_gu"
    t.string "other_details_hi"
    t.string "description_en"
    t.string "description_gu"
    t.string "description_hi"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "product_type_id", null: false
    t.integer "priority", default: 0
    t.index ["product_type_id"], name: "index_products_on_product_type_id"
  end

  create_table "reports", force: :cascade do |t|
    t.string "description"
    t.integer "user_id", null: false
    t.integer "reported_user_id", null: false
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_delete", default: false
  end

  create_table "soil_types", force: :cascade do |t|
    t.string "name_en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name_gu"
    t.string "name_hi"
  end

  create_table "solutions", force: :cascade do |t|
    t.string "title_en"
    t.string "title_gu"
    t.string "title_hi"
    t.string "description_en"
    t.string "description_gu"
    t.string "description_hi"
    t.string "sub_title_en"
    t.string "sub_title_gu"
    t.string "sub_title_hi"
    t.bigint "problem_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["problem_id"], name: "index_solutions_on_problem_id"
  end

  create_table "states", force: :cascade do |t|
    t.string "name_en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name_gu"
    t.string "name_hi"
  end

  create_table "sub_comments", force: :cascade do |t|
    t.string "discription"
    t.bigint "comment_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: true
    t.index ["comment_id"], name: "index_sub_comments_on_comment_id"
    t.index ["user_id"], name: "index_sub_comments_on_user_id"
  end

  create_table "user_tokens", force: :cascade do |t|
    t.string "devise_id", null: false
    t.boolean "login", default: true
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["devise_id"], name: "index_user_tokens_on_devise_id"
    t.index ["user_id"], name: "index_user_tokens_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", default: ""
    t.string "last_name", default: ""
    t.string "village", default: ""
    t.string "mobile_no"
    t.string "otp"
    t.integer "language"
    t.boolean "active", default: false
    t.integer "favourite_crops", default: [], array: true
    t.bigint "state_id"
    t.bigint "district_id"
    t.bigint "soil_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.index ["district_id"], name: "index_users_on_district_id"
    t.index ["soil_type_id"], name: "index_users_on_soil_type_id"
    t.index ["state_id"], name: "index_users_on_state_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "complaints", "comments"
  add_foreign_key "complaints", "posts"
  add_foreign_key "complaints", "sub_comments"
  add_foreign_key "complaints", "users"
  add_foreign_key "crops", "crop_categories"
  add_foreign_key "districts", "states"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "fertilizer_items", "fertilizer_schedules"
  add_foreign_key "fertilizer_schedules", "crops"
  add_foreign_key "likes", "posts"
  add_foreign_key "likes", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "problems", "crops"
  add_foreign_key "product_uniquenesses", "products"
  add_foreign_key "products", "product_types"
  add_foreign_key "solutions", "problems"
  add_foreign_key "sub_comments", "comments"
  add_foreign_key "sub_comments", "users"
  add_foreign_key "user_tokens", "users"
  add_foreign_key "users", "districts"
  add_foreign_key "users", "soil_types"
  add_foreign_key "users", "states"
end
