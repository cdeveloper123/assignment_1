class CreateBudgetProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :budget_projects do |t|
      t.references :budget, null: false, foreign_key: true
      t.references :budget_category, null: false, foreign_key: true
      t.references :voting_phase, null: true, foreign_key: true # Enhancement 2: Multi-phase voting
      t.references :user, null: false, foreign_key: true # Project creator
      
      t.string :title, null: false
      t.text :description
      t.decimal :requested_amount, precision: 12, scale: 2, null: false
      t.text :justification
      t.string :status, default: 'pending' # pending, approved, rejected, implemented
      t.integer :votes_count, default: 0
      t.decimal :allocated_amount, precision: 12, scale: 2, default: 0
      
      t.timestamps
    end

    add_index :budget_projects, [:budget_id, :status]
    add_index :budget_projects, :votes_count
  end
end 