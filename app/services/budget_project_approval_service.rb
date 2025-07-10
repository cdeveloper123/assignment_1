class BudgetProjectApprovalService
  def initialize(project, allocation = nil)
    @project = project
    @allocation = allocation || project.requested_amount
  end

  def approve!
    unless @project.budget.category_within_limit?(@project.budget_category, @allocation)
      @project.errors.add(:base, "Approval would exceed category spending limit")
      return false
    end
    @project.update!(status: 'approved', allocated_amount: @allocation)
  end
end 