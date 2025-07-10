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

ActiveRecord::Schema[8.0].define(version: 9) do
  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.integer "resource_id"
    t.string "author_type"
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "budget_categories", force: :cascade do |t|
    t.integer "budget_id", null: false
    t.string "name", null: false
    t.text "description"
    t.string "color", default: "#007bff"
    t.integer "spending_limit_percentage", default: 100
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["budget_id", "name"], name: "index_budget_categories_on_budget_id_and_name", unique: true
    t.index ["budget_id"], name: "index_budget_categories_on_budget_id"
  end

  create_table "budget_projects", force: :cascade do |t|
    t.integer "budget_id", null: false
    t.integer "budget_category_id", null: false
    t.integer "voting_phase_id"
    t.integer "user_id", null: false
    t.string "title", null: false
    t.text "description"
    t.decimal "requested_amount", precision: 12, scale: 2, null: false
    t.text "justification"
    t.string "status", default: "pending"
    t.integer "votes_count", default: 0
    t.decimal "allocated_amount", precision: 12, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["budget_category_id"], name: "index_budget_projects_on_budget_category_id"
    t.index ["budget_id", "status"], name: "index_budget_projects_on_budget_id_and_status"
    t.index ["budget_id"], name: "index_budget_projects_on_budget_id"
    t.index ["user_id"], name: "index_budget_projects_on_user_id"
    t.index ["votes_count"], name: "index_budget_projects_on_votes_count"
    t.index ["voting_phase_id"], name: "index_budget_projects_on_voting_phase_id"
  end

  create_table "budgets", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "total_funds", precision: 12, scale: 2, null: false
    t.date "voting_start_date"
    t.date "voting_end_date"
    t.boolean "active", default: true
    t.string "status", default: "planning"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_budgets_on_active"
    t.index ["status"], name: "index_budgets_on_status"
  end

  create_table "impact_metrics", force: :cascade do |t|
    t.integer "budget_project_id", null: false
    t.integer "estimated_beneficiaries", default: 0
    t.string "timeline"
    t.integer "sustainability_score", default: 1
    t.text "environmental_impact"
    t.text "social_impact"
    t.text "economic_impact"
    t.decimal "cost_per_beneficiary", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["budget_project_id"], name: "index_impact_metrics_on_budget_project_id"
    t.index ["estimated_beneficiaries"], name: "index_impact_metrics_on_estimated_beneficiaries"
    t.index ["sustainability_score"], name: "index_impact_metrics_on_sustainability_score"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.integer "available_votes", default: 5
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "budget_project_id", null: false
    t.integer "voting_phase_id"
    t.decimal "vote_weight", precision: 5, scale: 2, default: "1.0"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["budget_project_id"], name: "index_votes_on_budget_project_id"
    t.index ["user_id", "budget_project_id"], name: "index_votes_on_user_id_and_budget_project_id", unique: true
    t.index ["user_id"], name: "index_votes_on_user_id"
    t.index ["voting_phase_id", "user_id"], name: "index_votes_on_voting_phase_id_and_user_id"
    t.index ["voting_phase_id"], name: "index_votes_on_voting_phase_id"
  end

  create_table "voting_phases", force: :cascade do |t|
    t.integer "budget_id", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "start_date", null: false
    t.datetime "end_date", null: false
    t.text "rules"
    t.integer "max_votes_per_user", default: 5
    t.integer "position", default: 0
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_voting_phases_on_active"
    t.index ["budget_id", "start_date"], name: "index_voting_phases_on_budget_id_and_start_date"
    t.index ["budget_id"], name: "index_voting_phases_on_budget_id"
  end

  add_foreign_key "budget_categories", "budgets"
  add_foreign_key "budget_projects", "budget_categories"
  add_foreign_key "budget_projects", "budgets"
  add_foreign_key "budget_projects", "users"
  add_foreign_key "budget_projects", "voting_phases"
  add_foreign_key "impact_metrics", "budget_projects"
  add_foreign_key "votes", "budget_projects"
  add_foreign_key "votes", "users"
  add_foreign_key "votes", "voting_phases"
  add_foreign_key "voting_phases", "budgets"
end
