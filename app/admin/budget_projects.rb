ActiveAdmin.register BudgetProject do
  permit_params :budget_id, :budget_category_id, :voting_phase_id, :user_id,
                :title, :description, :requested_amount, :justification, :status, :allocated_amount

  index do
    selectable_column
    id_column
    column :title do |project|
      link_to project.title, admin_budget_project_path(project)
    end
    column :budget
    column :budget_category
    column :voting_phase
    column :user do |project|
      project.user.full_name
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
      score = project.impact_metric&.overall_impact_score.to_f
      badge_text = if score >= 8
                      "Very High (#{score.round(1)})"
                   elsif score >= 6
                      "High (#{score.round(1)})"
                   elsif score >= 3
                      "Medium (#{score.round(1)})"
                   else
                      "Low (#{score.round(1)})"
                   end
      status_tag badge_text, class: score >= 6 ? 'ok' : 'warning'
    end
    column :created_at
    actions do |project|
      if project.status == 'pending' && project.can_be_approved?
        item "Approve", approve_admin_budget_project_path(project), 
             method: :patch, class: "member_link"
      end
      if project.status == 'pending'
        item "Reject", reject_admin_budget_project_path(project), 
             method: :patch, class: "member_link"
      end
    end
  end

  filter :budget
  filter :budget_category
  filter :voting_phase
  filter :status, as: :select, collection: %w[pending approved rejected implemented]
  filter :votes_count
  filter :requested_amount
  filter :created_at

  scope :all, default: true
  scope :pending
  scope :approved
  scope :rejected
  scope :high_impact

  show do
    attributes_table do
      row :title
      row :description
      row :budget
      row :budget_category
      row :voting_phase
      row :user do
        resource.user.full_name
      end
      row :status do
        status_tag resource.status
      end
      row :requested_amount do
        number_to_currency(resource.requested_amount)
      end
      row :allocated_amount do
        number_to_currency(resource.allocated_amount)
      end
      row :votes_count
      row :justification
      row :created_at
      row :updated_at
    end

    # Enhancement 3: Impact Assessment Details
    if resource.impact_metric
      panel "Impact Assessment" do
        impact = resource.impact_metric
        
        div class: "row" do
          div class: "col-md-6" do
            h4 "Impact Metrics"
            ul do
              li "Estimated Beneficiaries: #{impact.estimated_beneficiaries}"
              li "Sustainability Score: #{impact.sustainability_score}/10 (#{impact.sustainability_level})"
              li "Timeline: #{impact.timeline}"
              li "Overall Impact Score: #{impact.overall_impact_score.round(2)}/10"
              li "Impact Category: #{status_tag impact.impact_category}"
              if impact.cost_per_beneficiary
                li "Cost per Beneficiary: #{number_to_currency(impact.cost_per_beneficiary)}"
              end
            end
          end
          div class: "col-md-6" do
            h4 "Impact Types"
            ul do
              if impact.has_environmental_impact?
                li "Environmental Impact: #{truncate(impact.environmental_impact, length: 100)}"
              end
              if impact.has_social_impact?
                li "Social Impact: #{truncate(impact.social_impact, length: 100)}"
              end
              if impact.has_economic_impact?
                li "Economic Impact: #{truncate(impact.economic_impact, length: 100)}"
              end
            end
          end
        end
      end
    end

    # Enhancement 1: Category Limit Impact
    panel "Category Spending Analysis" do
      category = resource.budget_category
      div class: "row" do
        div class: "col-md-6" do
          h4 "Current Category Status"
          ul do
            li "Category: #{category.name}"
            li "Spending Limit: #{category.spending_limit_percentage}%"
            li "Current Utilization: #{category.utilization_percent.round(2)}%"
            li "Limit Amount: #{number_to_currency(category.limit_amount)}"
            li "Already Allocated: #{number_to_currency(category.total_allocated)}"
            li "Remaining: #{number_to_currency(category.remaining_limit)}"
          end
        end
        div class: "col-md-6" do
          h4 "Impact if Approved"
          if resource.status == 'pending'
            utilization_after = resource.category_utilization_after_approval
            ul do
              li "Utilization after approval: #{utilization_after.round(2)}%"
              li "Would exceed limit: #{resource.would_exceed_category_limit? ? 'Yes' : 'No'}"
            end
            
            if resource.would_exceed_category_limit?
              div class: "alert alert-danger" do
                "⚠️ Approving this project would exceed the category spending limit!"
              end
            elsif utilization_after > 90
              div class: "alert alert-warning" do
                "⚠️ Approving this project would bring category utilization above 90%"
              end
            end
          else
            p "Project status: #{resource.status.titleize}"
          end
        end
      end
    end

    # Enhancement 2: Voting Phase Information
    if resource.voting_phase
      panel "Voting Phase Information" do
        phase = resource.voting_phase
        ul do
          li "Phase: #{phase.name}"
          li "Status: #{status_tag phase.status}"
          li "Duration: #{phase.start_date} to #{phase.end_date}"
          li "Votes in phase: #{phase.votes_cast_count}"
          li "Participants: #{phase.participating_users_count}"
        end
      end
    end

    panel "Voting Activity" do
      table_for resource.votes.includes(:user).recent.limit(10) do
        column "Voter" do |vote|
          vote.user.full_name
        end
        column :vote_weight
        column :comment
        column :created_at
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :budget, as: :select, collection: Budget.active.order(:name), input_html: { value: f.object.budget_id }
      f.input :budget_category, as: :select, 
              collection: option_groups_from_collection_for_select(
                Budget.active.includes(:budget_categories), 
                :budget_categories, :name, :id, :name,
                f.object.budget_category_id
              ), input_html: { value: f.object.budget_category_id }
      f.input :voting_phase, as: :select,
              collection: option_groups_from_collection_for_select(
                Budget.active.includes(:voting_phases),
                :voting_phases, :name, :id, :name,
                f.object.voting_phase_id
              ),
              include_blank: "No specific phase", input_html: { value: f.object.voting_phase_id }
      f.input :user, as: :select, collection: User.order(:first_name, :last_name), input_html: { value: f.object.user_id }
      f.input :title, input_html: { value: f.object.title }
      f.input :description, input_html: { value: f.object.description }
      f.input :requested_amount, input_html: { value: f.object.requested_amount }
      f.input :allocated_amount, input_html: { value: f.object.allocated_amount }
      f.input :justification, input_html: { value: f.object.justification }
      f.input :status, as: :select, collection: %w[pending approved rejected implemented], input_html: { value: f.object.status }
    end
    f.actions
  end

  # Enhancement 1: Approval with category limit checking
  member_action :approve, method: :patch do
    @project = resource
    
    unless @project.can_be_approved?
      redirect_to admin_budget_project_path(@project),
                  alert: "Cannot approve: would exceed category spending limit"
      return
    end
    
    if @project.approve_with_allocation!
      redirect_to admin_budget_project_path(@project),
                  notice: "Project approved successfully"
    else
      redirect_to admin_budget_project_path(@project),
                  alert: @project.errors.full_messages.join(", ")
    end
  end

  member_action :reject, method: :patch do
    @project = resource
    reason = params[:reason] || "Rejected by admin"
    
    if @project.reject_with_reason!(reason)
      redirect_to admin_budget_project_path(@project),
                  notice: "Project rejected"
    else
      redirect_to admin_budget_project_path(@project),
                  alert: "Failed to reject project"
    end
  end

  # Batch actions for project management
  batch_action :approve_projects do |ids|
    approved_count = 0
    failed_count = 0
    
    batch_action_collection.find(ids).each do |project|
      if project.can_be_approved? && project.approve_with_allocation!
        approved_count += 1
      else
        failed_count += 1
      end
    end
    
    redirect_to collection_path, 
                notice: "Approved #{approved_count} projects. #{failed_count} failed due to category limits."
  end

  batch_action :reject_projects do |ids|
    batch_action_collection.find(ids).each do |project|
      project.reject_with_reason!("Batch rejection by admin")
    end
    redirect_to collection_path, notice: "Rejected #{ids.count} projects"
  end
end 