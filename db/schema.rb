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

ActiveRecord::Schema[8.1].define(version: 2026_09_26_215205) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_job_durable_runs", force: :cascade do |t|
    t.string "job_class", null: false
    t.string "key", null: false
    t.string "active_key"
    t.string "active_job_id", null: false
    t.json "arguments", null: false
    t.string "status", null: false
    t.string "current_step"
    t.json "completed_steps", null: false
    t.json "state", null: false
    t.datetime "wake_at"
    t.json "pending_signals", null: false
    t.json "parked_job"
    t.integer "resumptions", default: 0, null: false
    t.datetime "last_heartbeat_at"
    t.string "error_class"
    t.text "error_message"
    t.string "halt_reason"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "transitioned_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_active_job_durable_runs_on_active_job_id", unique: true
    t.index ["job_class", "active_key"], name: "index_active_job_durable_runs_on_active_key", unique: true
    t.index ["job_class", "key"], name: "index_active_job_durable_runs_on_key"
    t.index ["status", "transitioned_at"], name: "index_active_job_durable_runs_on_status_and_transitioned_at"
    t.index ["status", "wake_at"], name: "index_active_job_durable_runs_on_status_and_wake_at"
    t.index ["status"], name: "index_active_job_durable_runs_on_status"
  end

  create_table "active_job_durable_steps", force: :cascade do |t|
    t.integer "run_id", null: false
    t.string "name", null: false
    t.integer "position", null: false
    t.integer "attempt", default: 1, null: false
    t.string "status", null: false
    t.json "cursor"
    t.boolean "isolated", default: false, null: false
    t.string "error_class"
    t.text "error_message"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.index ["run_id", "name", "attempt"], name: "index_active_job_durable_steps_on_attempt", unique: true
    t.index ["run_id", "position"], name: "index_active_job_durable_steps_on_position"
  end

  create_table "import_items", force: :cascade do |t|
    t.integer "import_id", null: false
    t.string "label"
    t.boolean "processed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["import_id"], name: "index_import_items_on_import_id"
  end

  create_table "imports", force: :cascade do |t|
    t.string "name"
    t.boolean "confirmed"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "licenses", force: :cascade do |t|
    t.string "identifier"
    t.datetime "expires_at"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_job_durable_steps", "active_job_durable_runs", column: "run_id", on_delete: :cascade
  add_foreign_key "import_items", "imports"
end
