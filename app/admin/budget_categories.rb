ActiveAdmin.register BudgetCategory do
  permit_params :budget_id, :name, :description, :color, :spending_limit_percentage, :position

  index do
    selectable_column
    id_column
    column :budget
    column :name
    column :description do |category|
      truncate(category.description, length: 100)
    end
    column "Spending Limit" do |category|
      "#{category.spending_limit_percentage}%"
    end
    column "Utilization" do |category|
      progress_bar = content_tag :div, class: 'progress', style: 'width: 200px;' do
        content_tag :div, '',
                    class: "progress-bar bg-#{category.utilization_status == 'over_limit' ? 'danger' : 'info'}",
                    style: "width: #{[category.utilization_percent, 100].min}%"
      end
      progress_bar + "<br/><small>#{category.utilization_percent.round(1)}%</small>".html_safe
    end
    column "Projects" do |category|
      "#{category.approved_projects_count}/#{category.projects_count}"
    end
    column :position
    actions do |category|
      item "Update Limit", edit_limit_admin_budget_category_path(category), class: "member_link"
    end
  end

  filter :budget
  filter :name
  filter :spending_limit_percentage
  filter :created_at

  show do
    attributes_table do
      row :budget
      row :name
      row :description
      row :color do |category|
        content_tag :div, '', style: "width: 20px; height: 20px; background-color: #{category.color}; display: inline-block; margin-right: 10px;" 
      end
      row :spending_limit_percentage do |category|
        "#{category.spending_limit_percentage}%"
      end
      row :position
      row :created_at
      row :updated_at
    end

    # Enhancement 1: Category utilization details
    panel "Spending Limit Analysis" do
      div class: "row" do
        div class: "col-md-6" do
          h4 "Current Utilization"
          ul do
            li "Limit Amount: #{number_to_currency(resource.limit_amount)}"
            li "Allocated: #{number_to_currency(resource.total_allocated)}"
            li "Remaining: #{number_to_currency(resource.remaining_limit)}"
            li "Utilization: #{resource.utilization_percent.round(2)}%"
            li "Status: #{status_tag resource.utilization_status}"
          end
        end
        div class: "col-md-6" do
          h4 "Project Summary"
          ul do
            li "Total Projects: #{resource.projects_count}"
            li "Approved: #{resource.approved_projects_count}"
            li "Pending: #{resource.pending_projects_count}"
            li "Total Requested: #{number_to_currency(resource.total_requested)}"
          end
        end
      end
      
      if resource.near_limit?
        div class: "alert alert-warning" do
          "⚠️ This category is near its spending limit (#{resource.utilization_percent.round(1)}%)"
        end
      end
      
      if resource.over_limit?
        div class: "alert alert-danger" do
          "🚨 This category has exceeded its spending limit!"
        end
      end
    end

    panel "Projects in Category" do
      table_for resource.budget_projects.order(votes_count: :desc) do
        column :title do |project|
          link_to project.title, admin_budget_project_path(project)
        end
        column :status do |project|
          status_tag project.status
        end
        column :requested_amount do |project|
          number_to_currency(project.requested_amount)
        end
        column :allocated_amount do |project|
          number_to_currency(project.allocated_amount)
        end
        column :votes_count
        column "Impact Score" do |project|
          project.impact_score.round(2)
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :budget, as: :select, collection: Budget.active.order(:name), input_html: { value: f.object.budget_id }
      f.input :name, input_html: { value: f.object.name }
      f.input :description, input_html: { value: f.object.description }
      f.input :color, as: :string, input_html: { type: 'color', value: f.object.color }
      f.input :spending_limit_percentage, 
              hint: "Percentage of total budget that can be allocated to this category (1-100%)"
      f.input :position, input_html: { value: f.object.position }
    end
    f.actions
  end

  # Enhancement 1: Custom action for updating spending limits
  member_action :edit_limit, method: :get do
    @category = resource
    render inline: <<-ERB
      <h2>Update Spending Limit for <%= @category.name %></h2>
      <%= form_with url: update_limit_admin_budget_category_path(@category), method: :patch, local: true do |f| %>
        <div class="field">
          <%= f.label :spending_limit_percentage, 'Spending Limit (%)' %><br>
          <%= f.number_field :spending_limit_percentage, value: @category.spending_limit_percentage, min: 1, max: 100 %>
        </div>
        <div class="actions">
          <%= f.submit 'Update Limit', class: 'btn btn-primary' %>
        </div>
      <% end %>
      <%= link_to 'Back', admin_budget_category_path(@category), class: 'btn btn-secondary' %>
    ERB
  end

  member_action :update_limit, method: :patch do
    @category = resource
    new_limit = params[:spending_limit_percentage].to_i

    if new_limit < 1 || new_limit > 100
      redirect_to admin_budget_category_path(@category),
                  alert: 'Spending limit must be between 1% and 100%.'
      return
    end

    # Check if reducing limit would cause issues
    if new_limit < @category.spending_limit_percentage
      current_utilization = @category.utilization_percent
      if current_utilization > new_limit
        redirect_to admin_budget_category_path(@category),
                    alert: "Cannot reduce limit below current utilization of #{current_utilization.round(1)}%."
        return
      end
    end

    if @category.update(spending_limit_percentage: new_limit)
      redirect_to admin_budget_category_path(@category),
                  notice: "Spending limit updated to #{new_limit}%."
    else
      redirect_to admin_budget_category_path(@category),
                  alert: 'Failed to update spending limit.'
    end
  end

  # Batch action for updating multiple category limits
  batch_action :update_spending_limits do |ids|
    batch_action_collection.find(ids).each do |category|
      # This would open a form for batch updating - simplified for demo
      category.update(spending_limit_percentage: 50) # Default to 50%
    end
    redirect_to collection_path, alert: "Updated spending limits for #{ids.count} categories to 50%"
  end
end 