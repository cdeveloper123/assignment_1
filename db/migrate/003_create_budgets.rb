class CreateBudgets < ActiveRecord::Migration[7.0]
  def change
    create_table :budgets do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :total_funds, precision: 12, scale: 2, null: false
      t.date :voting_start_date
      t.date :voting_end_date
      t.boolean :active, default: true
      t.string :status, default: 'planning' # planning, voting, results, completed

      t.timestamps
    end

    add_index :budgets, :active
    add_index :budgets, :status
  end
end 