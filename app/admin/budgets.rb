ActiveAdmin.register Budget do
  permit_params :name, :description, :total_funds, :voting_start_date, 
                :voting_end_date, :active, :status

  index do
    selectable_column
    id_column
    column :name
    column :total_funds do |budget|
      number_to_currency(budget.total_funds)
    end
    column :status do |budget|
      status_tag budget.status, class: budget.status
    end
    column :voting_start_date
    column :voting_end_date
    column :active
    column "Projects" do |budget|
      budget.budget_projects.count
    end
    column "Total Votes" do |budget|
      budget.total_votes_cast
    end
    column :created_at
    actions do |budget|
      item "Dashboard", admin_dashboard_budget_path(budget), class: "member_link"
      item "Results", results_budget_path(budget), class: "member_link"
    end
  end

  filter :name
  filter :status, as: :select, collection: %w[planning voting results completed]
  filter :active
  filter :voting_start_date
  filter :voting_end_date
  filter :created_at

  show do
    attributes_table do
      row :name
      row :description
      row :total_funds do |budget|
        number_to_currency(budget.total_funds)
      end
      row :status do |budget|
        status_tag budget.status, class: budget.status
      end
      row :voting_start_date
      row :voting_end_date
      row :active
      row :created_at
      row :updated_at
    end

    panel "Budget Statistics" do
      div class: "row" do
        div class: "col-md-3" do
          h4 "Projects: #{budget.budget_projects.count}"
          ul do
            li "Pending: #{budget.budget_projects.pending.count}"
            li "Approved: #{budget.budget_projects.approved.count}"
            li "Rejected: #{budget.budget_projects.rejected.count}"
          end
        end
        div class: "col-md-3" do
          h4 "Funding"
          ul do
            li "Total: #{number_to_currency(budget.total_funds)}"
            li "Allocated: #{number_to_currency(budget.total_allocated)}"
            li "Remaining: #{number_to_currency(budget.remaining_funds)}"
            li "Utilization: #{budget.utilization_percentage}%"
          end
        end
        div class: "col-md-3" do
          h4 "Voting Activity"
          ul do
            li "Total Votes: #{budget.total_votes_cast}"
            li "Participants: #{budget.participating_users_count}"
          end
        end
        div class: "col-md-3" do
          h4 "Categories: #{budget.budget_categories.count}"
          h4 "Phases: #{budget.voting_phases.count}"
        end
      end
    end

    # Enhancement 1: Category limits overview
    panel "Category Spending Limits" do
      table_for budget.budget_categories.ordered do
        column :name
        column "Limit %" do |category|
          "#{category.spending_limit_percentage}%"
        end
        column "Utilization" do |category|
          progress_bar = content_tag :div, class: 'progress' do
            content_tag :div, '',
                        class: "progress-bar bg-#{category.utilization_status == 'over_limit' ? 'danger' : 'info'}",
                        style: "width: #{[category.utilization_percent, 100].min}%"
          end
          progress_bar + " #{category.utilization_percent.round(1)}%"
        end
        column "Status" do |category|
          status_tag category.utilization_status, 
                     class: case category.utilization_status
                           when 'low' then 'ok'
                           when 'medium' then 'warning'
                           when 'high', 'critical' then 'error'
                           when 'over_limit' then 'error'
                           end
        end
      end
    end

    # Enhancement 2: Voting phases overview
    if budget.voting_phases.any?
      panel "Voting Phases" do
        table_for budget.voting_phases.ordered do
          column :name
          column :start_date
          column :end_date
          column "Status" do |phase|
            status_tag phase.status, class: phase.status
          end
          column :active
          column "Projects" do |phase|
            phase.projects_count
          end
          column "Votes" do |phase|
            phase.votes_cast_count
          end
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
      f.input :total_funds, min: 0.01
      f.input :voting_start_date, as: :datetime_picker, input_html: { value: f.object.voting_start_date&.strftime('%Y-%m-%dT%H:%M') }
      f.input :voting_end_date, as: :datetime_picker, input_html: { value: f.object.voting_end_date&.strftime('%Y-%m-%dT%H:%M') }
      f.input :status, as: :select, collection: %w[planning voting results completed]
      f.input :active
    end
    f.actions
  end

  member_action :dashboard, method: :get do
    redirect_to admin_dashboard_budget_path(resource)
  end
end 