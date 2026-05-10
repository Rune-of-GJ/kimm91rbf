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

ActiveRecord::Schema[8.1].define(version: 2026_05_07_020000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "coaching_credit_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "credits_amount", null: false
    t.datetime "expires_at"
    t.string "label", null: false
    t.integer "remaining_credits", default: 0, null: false
    t.bigint "source_id"
    t.string "source_type"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["source_type", "source_id"], name: "index_coaching_credit_entries_on_source"
    t.index ["user_id", "created_at"], name: "index_coaching_credit_entries_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_coaching_credit_entries_on_user_id"
  end

  create_table "coaching_credit_usages", force: :cascade do |t|
    t.bigint "coaching_credit_entry_id", null: false
    t.datetime "created_at", null: false
    t.integer "credits_amount", default: 1, null: false
    t.bigint "feedback_request_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["coaching_credit_entry_id"], name: "index_coaching_credit_usages_on_coaching_credit_entry_id"
    t.index ["feedback_request_id", "coaching_credit_entry_id"], name: "index_credit_usages_on_request_and_entry", unique: true
    t.index ["feedback_request_id"], name: "index_coaching_credit_usages_on_feedback_request_id"
    t.index ["user_id"], name: "index_coaching_credit_usages_on_user_id"
  end

  create_table "coaching_products", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.integer "credits_amount", default: 1, null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.integer "price", default: 0, null: false
    t.string "slug", null: false
    t.string "tagline", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_coaching_products_on_active"
    t.index ["slug"], name: "index_coaching_products_on_slug", unique: true
  end

  create_table "coaching_purchases", force: :cascade do |t|
    t.bigint "coaching_product_id", null: false
    t.datetime "created_at", null: false
    t.integer "credits_amount", default: 0, null: false
    t.integer "paid_amount", default: 0, null: false
    t.string "status", default: "completed", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["coaching_product_id"], name: "index_coaching_purchases_on_coaching_product_id"
    t.index ["status"], name: "index_coaching_purchases_on_status"
    t.index ["user_id"], name: "index_coaching_purchases_on_user_id"
  end

  create_table "courses", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.date "end_date"
    t.date "enrollment_deadline"
    t.bigint "instructor_id"
    t.string "instructor_name", null: false
    t.integer "max_access_days"
    t.date "start_date"
    t.string "thumbnail_url"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_courses_on_category_id"
    t.index ["instructor_id"], name: "index_courses_on_instructor_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["user_id", "course_id"], name: "index_enrollments_on_user_id_and_course_id", unique: true
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "feedback_requests", force: :cascade do |t|
    t.bigint "applied_credit_entry_id"
    t.string "audio_reference", null: false
    t.bigint "course_id"
    t.datetime "created_at", null: false
    t.string "credit_label", null: false
    t.string "credit_source_preference", default: "membership_first", null: false
    t.bigint "instructor_id"
    t.bigint "lecture_id"
    t.text "note"
    t.text "response_summary"
    t.text "response_timecodes"
    t.datetime "reviewed_at"
    t.string "status", default: "queued", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "used_credits", default: 1, null: false
    t.bigint "user_id", null: false
    t.index ["applied_credit_entry_id"], name: "index_feedback_requests_on_applied_credit_entry_id"
    t.index ["course_id"], name: "index_feedback_requests_on_course_id"
    t.index ["instructor_id"], name: "index_feedback_requests_on_instructor_id"
    t.index ["lecture_id"], name: "index_feedback_requests_on_lecture_id"
    t.index ["status"], name: "index_feedback_requests_on_status"
    t.index ["user_id", "created_at"], name: "index_feedback_requests_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_feedback_requests_on_user_id"
  end

  create_table "lectures", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.integer "duration"
    t.integer "order_no", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "video_url", null: false
    t.index ["course_id", "order_no"], name: "index_lectures_on_course_id_and_order_no", unique: true
    t.index ["course_id"], name: "index_lectures_on_course_id"
  end

  create_table "membership_plans", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.boolean "featured", default: false, null: false
    t.integer "included_coaching_unit_price", default: 0, null: false
    t.integer "monthly_coaching_credits", default: 0, null: false
    t.integer "monthly_price", default: 0, null: false
    t.integer "monthly_rehearsal_limit", default: 0, null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.string "tagline", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_membership_plans_on_active"
    t.index ["slug"], name: "index_membership_plans_on_slug", unique: true
  end

  create_table "progresses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "lecture_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.boolean "watched", default: false, null: false
    t.datetime "watched_at"
    t.index ["lecture_id"], name: "index_progresses_on_lecture_id"
    t.index ["user_id", "lecture_id"], name: "index_progresses_on_user_id_and_lecture_id", unique: true
    t.index ["user_id"], name: "index_progresses_on_user_id"
  end

  create_table "rehearsal_submissions", force: :cascade do |t|
    t.bigint "course_id"
    t.datetime "created_at", null: false
    t.bigint "lecture_id"
    t.text "note"
    t.string "source_label", default: "manual", null: false
    t.datetime "submitted_at", null: false
    t.bigint "subscription_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["course_id"], name: "index_rehearsal_submissions_on_course_id"
    t.index ["lecture_id"], name: "index_rehearsal_submissions_on_lecture_id"
    t.index ["subscription_id"], name: "index_rehearsal_submissions_on_subscription_id"
    t.index ["user_id", "submitted_at"], name: "index_rehearsal_submissions_on_user_and_submitted_at"
    t.index ["user_id"], name: "index_rehearsal_submissions_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "canceled_at"
    t.datetime "created_at", null: false
    t.datetime "current_period_end", null: false
    t.bigint "membership_plan_id", null: false
    t.datetime "started_at", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["membership_plan_id"], name: "index_subscriptions_on_membership_plan_id"
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["user_id", "status"], name: "index_subscriptions_on_user_id_and_status"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "role", default: "student", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "coaching_credit_entries", "users"
  add_foreign_key "coaching_credit_usages", "coaching_credit_entries"
  add_foreign_key "coaching_credit_usages", "feedback_requests"
  add_foreign_key "coaching_credit_usages", "users"
  add_foreign_key "coaching_purchases", "coaching_products"
  add_foreign_key "coaching_purchases", "users"
  add_foreign_key "courses", "categories"
  add_foreign_key "courses", "users", column: "instructor_id"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "users"
  add_foreign_key "feedback_requests", "coaching_credit_entries", column: "applied_credit_entry_id"
  add_foreign_key "feedback_requests", "courses"
  add_foreign_key "feedback_requests", "lectures"
  add_foreign_key "feedback_requests", "users"
  add_foreign_key "feedback_requests", "users", column: "instructor_id"
  add_foreign_key "lectures", "courses"
  add_foreign_key "progresses", "lectures"
  add_foreign_key "progresses", "users"
  add_foreign_key "rehearsal_submissions", "courses"
  add_foreign_key "rehearsal_submissions", "lectures"
  add_foreign_key "rehearsal_submissions", "subscriptions"
  add_foreign_key "rehearsal_submissions", "users"
  add_foreign_key "subscriptions", "membership_plans"
  add_foreign_key "subscriptions", "users"
end
