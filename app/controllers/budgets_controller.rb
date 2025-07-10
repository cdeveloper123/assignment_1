class BudgetsController < ApplicationController
  before_action :set_budget, only: [:show, :results, :admin_dashboard]
  
  def index
    @budgets = Budget.active.includes(:budget_categories, :voting_phases)
    @current_budgets = @budgets.voting_active
    @completed_budgets = @budgets.where(status: ['results', 'completed'])
  end

  def show
    @budget_categories = @budget.budget_categories.ordered.includes(:budget_projects)
    @budget_projects = @budget.budget_projects.includes(:budget_category, :impact_metric, :user, :votes)
                              .order(votes_count: :desc)
    
    # Filter by category if specified
    if params[:category_id].present?
      @selected_category = @budget.budget_categories.find(params[:category_id])
      @budget_projects = @budget_projects.where(budget_category: @selected_category)
    end

    # Filter by impact criteria (Enhancement 3)
    case params[:sort_by]
    when 'impact_score'
      @budget_projects = @budget_projects.by_impact_score
    when 'sustainability'
      @budget_projects = @budget_projects.by_sustainability  
    when 'cost_effectiveness'
      @budget_projects = @budget_projects.by_cost_effectiveness
    when 'beneficiaries'
      @budget_projects = @budget_projects.joins(:impact_metric)
                                         .order('impact_metrics.estimated_beneficiaries DESC')
    else
      @budget_projects = @budget_projects.by_votes_desc
    end

    # Phase filtering (Enhancement 2)
    @current_phase = @budget.current_phase || @budget.active_phase
    if params[:phase_id].present?
      @selected_phase = @budget.voting_phases.find(params[:phase_id])
      @budget_projects = @budget_projects.where(voting_phase: @selected_phase)
    elsif @current_phase
      @budget_projects = @budget_projects.where(voting_phase: @current_phase)
    end

    @voting_phases = @budget.voting_phases.ordered
    @user_votes_remaining = current_user&.votes_remaining_for_budget(@budget) || 0
  end

  def results
    @approved_projects = @budget.budget_projects.approved
                                .includes(:budget_category, :impact_metric, :user)
                                .order(allocated_amount: :desc)
    
    @category_allocations = @budget.budget_categories.includes(:budget_projects)
                                   .map do |category|
      {
        category: category,
        allocated: category.total_allocated,
        utilization: category.utilization_percent,
        projects_count: category.approved_projects_count
      }
    end

    @total_allocated = @budget.total_allocated
    @remaining_funds = @budget.remaining_funds
    @total_votes = @budget.total_votes_cast
    @participating_users = @budget.participating_users_count

    # Phase results (Enhancement 2)
    @phase_results = @budget.voting_phases.ordered.map do |phase|
      {
        phase: phase,
        votes_count: phase.votes_cast_count,
        projects_count: phase.projects_count,
        participants_count: phase.participating_users_count
      }
    end
  end

  def admin_dashboard
    return redirect_to root_path unless current_admin_user

    @budget_stats = {
      total_projects: @budget.budget_projects.count,
      pending_projects: @budget.budget_projects.pending.count,
      approved_projects: @budget.budget_projects.approved.count,
      total_votes: @budget.total_votes_cast,
      participating_users: @budget.participating_users_count,
      funds_allocated: @budget.total_allocated,
      funds_remaining: @budget.remaining_funds
    }

    # Enhancement 1: Category utilization data
    @category_utilizations = @budget.budget_categories.ordered.map do |category|
      {
        category: category,
        utilization_percent: category.utilization_percent,
        status: category.utilization_status,
        remaining_limit: category.remaining_limit,
        projects_pending: category.pending_projects_count
      }
    end

    # Enhancement 2: Phase analytics
    @phase_analytics = @budget.voting_phases.ordered.map do |phase|
      {
        phase: phase,
        status: phase.status,
        votes_count: phase.votes_cast_count,
        projects_count: phase.projects_count,
        participation_rate: phase.participating_users_count
      }
    end

    # Projects needing attention
    @projects_over_category_limit = @budget.budget_projects.pending
                                           .select { |p| p.would_exceed_category_limit? }
    
    @high_impact_projects = @budget.budget_projects.pending.high_impact.limit(10)
  end

  private

  def set_budget
    @budget = Budget.find(params[:id])
  end
end 