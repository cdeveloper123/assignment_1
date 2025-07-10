ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "System Overview" do
          ul do
            li "Total Budgets: #{Budget.count}"
            li "Active Budgets: #{Budget.active.count}"
            li "Total Projects: #{BudgetProject.count}"
            li "Approved Projects: #{BudgetProject.approved.count}"
            li "Total Users: #{User.count}"
            li "Total Admin Users: #{AdminUser.count}"
          end
        end

        # Enhancement 1: Category Spending Overview
        panel "Category Spending Status" do
          categories_at_risk = BudgetCategory.joins(:budget_projects)
                                           .where(budget_projects: { status: 'approved' })
                                           .select { |c| c.utilization_percent > 80 }
          
          if categories_at_risk.any?
            div class: "alert alert-warning" do
              "⚠️ #{categories_at_risk.count} categories are above 80% utilization"
            end
            
            table_for categories_at_risk do
              column :budget
              column :name
              column "Utilization" do |cat|
                "#{cat.utilization_percent.round(1)}%"
              end
              column "Status" do |cat|
                status_tag cat.utilization_status
              end
            end
          else
            div class: "alert alert-success" do
              "✅ All categories are within safe spending limits"
            end
          end
        end
      end

      column do
        # Enhancement 2: Voting Phases Status
        panel "Active Voting Phases" do
          active_phases = VotingPhase.active.includes(:budget)
          
          if active_phases.any?
            table_for active_phases do
              column :budget
              column :name
              column :start_date
              column :end_date
              column "Votes" do |phase|
                phase.votes_cast_count
              end
              column "Status" do |phase|
                status_tag phase.status
              end
            end
          else
            div class: "alert alert-info" do
              "No active voting phases currently"
            end
          end
        end

        panel "Recent Activity" do
          votes = Vote.includes(:user, :budget_project).recent.limit(5)
          
          if votes.any?
            ul do
              votes.each do |vote|
                li "#{vote.user.full_name} voted for '#{truncate(vote.budget_project.title, length: 50)}' (#{time_ago_in_words(vote.created_at)} ago)"
              end
            end
          else
            p "No recent voting activity"
          end
        end
      end
    end

    columns do
      column do
        # Enhancement 3: Impact Assessment Overview
        panel "Impact Assessment Summary" do
          high_impact_projects = BudgetProject.joins(:impact_metric)
                                            .where('impact_metrics.estimated_beneficiaries >= ? AND impact_metrics.sustainability_score >= ?', 100, 7)
                                            .approved
          
          total_beneficiaries = BudgetProject.approved.joins(:impact_metric).sum('impact_metrics.estimated_beneficiaries')
          
          div class: "row" do
            div class: "col-md-6" do
              h4 "Impact Statistics"
              ul do
                li "High Impact Approved Projects: #{high_impact_projects.count}"
                li "Total Beneficiaries (Approved): #{total_beneficiaries.to_i}"
                li "Average Impact Score: #{BudgetProject.approved.joins(:impact_metric).average('impact_metrics.sustainability_score')&.round(2) || 0}"
              end
            end
            div class: "col-md-6" do
              h4 "Recent High Impact Projects"
              if high_impact_projects.any?
                ul do
                  high_impact_projects.limit(3).each do |project|
                    li link_to(project.title, admin_budget_project_path(project))
                  end
                end
              else
                p "No high impact projects yet"
              end
            end
          end
        end
      end

      column do
        panel "Budget Allocation Chart" do
          # This would integrate with Chartkick for visual charts
          active_budgets = Budget.active
          
          if active_budgets.any?
            div id: "budget-chart" do
              # Placeholder for chart - would use Chartkick in real implementation
              table do
                tr do
                  th "Budget"
                  th "Total Funds"
                  th "Allocated"
                  th "Utilization %"
                end
                active_budgets.each do |budget|
                  tr do
                    td link_to(budget.name, admin_budget_path(budget))
                    td number_to_currency(budget.total_funds)
                    td number_to_currency(budget.total_allocated)
                    td "#{budget.utilization_percentage}%"
                  end
                end
              end
            end
          else
            p "No active budgets to display"
          end
        end

        panel "Quick Actions" do
          ul do
            li link_to("Create New Budget", new_admin_budget_path, class: "button")
            li link_to("Manage Categories", admin_budget_categories_path, class: "button")
            li link_to("View Voting Phases", admin_voting_phases_path, class: "button")
            if defined?(admin_impact_reports_path)
              li link_to("Impact Reports", admin_impact_reports_path, class: "button")
            else
              li link_to("Impact Reports", "/admin/impact_reports", class: "button")
            end
            li link_to("Approve Pending Projects", admin_budget_projects_path(q: { status_eq: 'pending' }), class: "button")
          end
        end
      end
    end

    # Enhancement alerts
    columns do
      column span: 2 do
        panel "System Alerts & Recommendations" do
          alerts = []
          
          # Category limit alerts
          over_limit_categories = BudgetCategory.joins(:budget_projects)
                                              .where(budget_projects: { status: 'approved' })
                                              .select { |c| c.over_limit? }
          
          if over_limit_categories.any?
            alerts << { type: 'error', message: "#{over_limit_categories.count} categories have exceeded spending limits" }
          end
          
          # Pending high-impact projects
          pending_high_impact = BudgetProject.pending.joins(:impact_metric)
                                           .where('impact_metrics.sustainability_score >= ?', 8)
                                           .count
          
          if pending_high_impact > 0
            alerts << { type: 'warning', message: "#{pending_high_impact} high-impact projects are pending approval" }
          end
          
          # Phase transition alerts
          ending_phases = VotingPhase.active.where('end_date <= ?', 3.days.from_now)
          if ending_phases.any?
            alerts << { type: 'info', message: "#{ending_phases.count} voting phases ending within 3 days" }
          end
          
          if alerts.any?
            alerts.each do |alert|
              div class: "alert alert-#{alert[:type]}" do
                alert[:message]
              end
            end
          else
            div class: "alert alert-success" do
              "✅ No system alerts at this time"
            end
          end
        end
      end
    end
  end
end 