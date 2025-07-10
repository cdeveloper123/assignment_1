class BudgetProjectsController < ApplicationController
  before_action :set_budget
  before_action :set_budget_project, only: [:show, :edit, :update, :destroy, :vote, :remove_vote]
  before_action :check_project_owner, only: [:edit, :update, :destroy]

  def index
    redirect_to @budget
  end

  def show
    @impact_metric = @budget_project.impact_metric
    @user_vote = current_user&.vote_by_user(current_user) if current_user
    @can_vote = current_user&.can_vote_for_project?(@budget_project)
    
    # Category utilization info (Enhancement 1)
    @category_utilization = {
      current: @budget_project.budget_category.utilization_percent,
      after_approval: @budget_project.category_utilization_after_approval,
      would_exceed: @budget_project.would_exceed_category_limit?
    }

    # Phase information (Enhancement 2)
    @voting_phase = @budget_project.voting_phase
    @phase_votes_remaining = @voting_phase&.votes_remaining_for_user(current_user) || 0
  end

  def new
    @budget_project = @budget.budget_projects.build
    @budget_project.build_impact_metric # Enhancement 3: Auto-build impact metric
    @budget_categories = @budget.budget_categories.ordered
    @voting_phases = @budget.voting_phases.ordered
  end

  def create
    @budget_project = @budget.budget_projects.build(budget_project_params)
    @budget_project.user = current_user

    # Enhancement 1: Check category limits before creating
    if @budget_project.would_exceed_category_limit?
      flash.now[:warning] = "This project would exceed the category spending limit of #{@budget_project.budget_category.spending_limit_percentage}%"
    end

    if @budget_project.save
      redirect_to [@budget, @budget_project], 
                  notice: 'Project was successfully created.'
    else
      @budget_categories = @budget.budget_categories.ordered
      @voting_phases = @budget.voting_phases.ordered
      render :new
    end
  end

  def edit
    @budget_categories = @budget.budget_categories.ordered
    @voting_phases = @budget.voting_phases.ordered
  end

  def update
    if @budget_project.update(budget_project_params)
      redirect_to [@budget, @budget_project], 
                  notice: 'Project was successfully updated.'
    else
      @budget_categories = @budget.budget_categories.ordered
      @voting_phases = @budget.voting_phases.ordered
      render :edit
    end
  end

  def destroy
    @budget_project.destroy
    redirect_to @budget, notice: 'Project was successfully deleted.'
  end

  # Enhancement 2 & 3: Voting with phase support
  def vote
    unless @budget_project.can_vote?(current_user)
      redirect_to @budget, alert: 'You cannot vote for this project.'
      return
    end

    # Determine voting phase
    voting_phase = @budget_project.voting_phase || @budget.current_phase

    vote = @budget_project.votes.build(
      user: current_user,
      voting_phase: voting_phase,
      vote_weight: params[:vote_weight]&.to_f || 1.0,
      comment: params[:comment]
    )

    if vote.save
      redirect_to @budget, notice: 'Your vote has been recorded!'
    else
      redirect_to @budget, alert: vote.errors.full_messages.join(', ')
    end
  end

  def remove_vote
    vote = @budget_project.votes.find_by(user: current_user)
    
    if vote
      vote.destroy
      redirect_to @budget, notice: 'Your vote has been removed.'
    else
      redirect_to @budget, alert: 'You have not voted for this project.'
    end
  end

  private

  def set_budget
    @budget = Budget.find(params[:budget_id])
  end

  def set_budget_project
    @budget_project = @budget.budget_projects.find(params[:id])
  end

  def check_project_owner
    unless @budget_project.user == current_user || current_user&.admin? || current_admin_user
      redirect_to @budget, alert: 'You can only edit your own projects.'
    end
  end

  def budget_project_params
    params.require(:budget_project).permit(
      :title, :description, :requested_amount, :justification,
      :budget_category_id, :voting_phase_id,
      impact_metric_attributes: [
        :id, :estimated_beneficiaries, :timeline, :sustainability_score,
        :environmental_impact, :social_impact, :economic_impact, :_destroy
      ]
    )
  end
end 