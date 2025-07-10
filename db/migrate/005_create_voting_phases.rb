class CreateVotingPhases < ActiveRecord::Migration[7.0]
  def change
    create_table :voting_phases do |t|
      t.references :budget, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false
      t.text :rules # JSON field for phase-specific rules
      t.integer :max_votes_per_user, default: 5
      t.integer :position, default: 0
      t.boolean :active, default: false

      t.timestamps
    end

    add_index :voting_phases, [:budget_id, :start_date]
    add_index :voting_phases, :active
  end
end 