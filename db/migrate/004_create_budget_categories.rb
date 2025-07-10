class CreateBudgetCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :budget_categories do |t|
      t.references :budget, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :color, default: '#007bff'
      t.integer :spending_limit_percentage, default: 100 # Enhancement 1: Category limits
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :budget_categories, [:budget_id, :name], unique: true
  end
end 