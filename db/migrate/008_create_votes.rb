class CreateVotes < ActiveRecord::Migration[7.0]
  def change
    create_table :votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :budget_project, null: false, foreign_key: true
      t.references :voting_phase, null: true, foreign_key: true
      t.decimal :vote_weight, precision: 5, scale: 2, default: 1.0 # For weighted voting
      t.text :comment

      t.timestamps
    end

    add_index :votes, [:user_id, :budget_project_id], unique: true
    add_index :votes, [:voting_phase_id, :user_id]
  end
end 