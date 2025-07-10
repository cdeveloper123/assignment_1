class CreateImpactMetrics < ActiveRecord::Migration[7.0]
  def change
    create_table :impact_metrics do |t|
      t.references :budget_project, null: false, foreign_key: true
      t.integer :estimated_beneficiaries, default: 0
      t.string :timeline # e.g., "6 months", "1 year", "ongoing"
      t.integer :sustainability_score, default: 1 # 1-10 scale
      t.text :environmental_impact
      t.text :social_impact
      t.text :economic_impact
      t.decimal :cost_per_beneficiary, precision: 10, scale: 2

      t.timestamps
    end

    add_index :impact_metrics, :estimated_beneficiaries
    add_index :impact_metrics, :sustainability_score
  end
end 