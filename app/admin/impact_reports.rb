ActiveAdmin.register_page "Impact Reports" do
  menu priority: 3, label: "Impact Reports"

  content title: "Impact Reports" do
    panel "High Impact Projects" do
      high_impact_projects = BudgetProject.joins(:impact_metric)
        .where('impact_metrics.estimated_beneficiaries >= ? AND impact_metrics.sustainability_score >= ?', 100, 7)
        .approved

      if high_impact_projects.any?
        table_for high_impact_projects do
          column :title
          column :budget
          column :budget_category
          column("Beneficiaries") { |p| p.impact_metric.estimated_beneficiaries }
          column("Sustainability") { |p| p.impact_metric.sustainability_score }
          column("Impact Score") { |p| p.impact_metric.overall_impact_score.round(2) }
        end
      else
        div "No high impact projects yet."
      end
    end

    panel "Impact Statistics" do
      total_beneficiaries = BudgetProject.approved.joins(:impact_metric).sum('impact_metrics.estimated_beneficiaries')
      avg_sustainability = BudgetProject.approved.joins(:impact_metric).average('impact_metrics.sustainability_score')
      div do
        ul do
          li "Total Beneficiaries (Approved): #{total_beneficiaries.to_i}"
          li "Average Sustainability Score: #{avg_sustainability&.round(2) || 0}"
        end
      end
    end
  end
end 