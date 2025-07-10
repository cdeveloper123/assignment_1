class BudgetCategory < ApplicationRecord
  belongs_to :budget
  has_many :budget_projects, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :budget_id }
  validates :spending_limit_percentage, presence: true, 
            numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :color, presence: true

  scope :ordered, -> { order(:position, :name) }

  # Enhancement 1: Category spending limit methods
  def total_allocated
    budget_projects.where(status: 'approved').sum(:allocated_amount)
  end

  def total_requested
    budget_projects.sum(:requested_amount)
  end

  def limit_amount
    budget.total_funds * spending_limit_percentage / 100
  end

  def utilization_percent
    return 0 if limit_amount.zero?
    (total_allocated / limit_amount * 100).round(2)
  end

  def remaining_limit
    limit_amount - total_allocated
  end

  def over_limit?
    total_allocated > limit_amount
  end

  def near_limit?(threshold = 90)
    utilization_percent >= threshold
  end

  def can_allocate?(amount)
    (total_allocated + amount) <= limit_amount
  end

  def utilization_status
    case utilization_percent
    when 0...50
      'low'
    when 50...80
      'medium'
    when 80...95
      'high'
    when 95..100
      'critical'
    else
      'over_limit'
    end
  end

  def projects_count
    budget_projects.count
  end

  def approved_projects_count
    budget_projects.where(status: 'approved').count
  end

  def pending_projects_count
    budget_projects.where(status: 'pending').count
  end

  def self.ransackable_associations(auth_object = nil)
    ["budget", "budget_projects"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["budget_id", "color", "created_at", "description", "id", "id_value", "name", "position", "spending_limit_percentage", "updated_at"]
  end
end 