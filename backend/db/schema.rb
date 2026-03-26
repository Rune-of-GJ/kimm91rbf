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

ActiveRecord::Schema[8.1].define(version: 2026_03_19_000600) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
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

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "role", default: "student", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "courses", "categories"
  add_foreign_key "courses", "users", column: "instructor_id"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "users"
  add_foreign_key "lectures", "courses"
  add_foreign_key "progresses", "lectures"
  add_foreign_key "progresses", "users"
end
