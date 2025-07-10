class Budget < ApplicationRecord
  has_many :budget_categories, dependent: :destroy
  has_many :budget_projects, dependent: :destroy
  has_many :voting_phases, dependent: :destroy
  has_many :votes, through: :budget_projects

  validates :name, presence: true
  validates :total_funds, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[planning voting results completed] }

  scope :active, -> { where(active: true) }
  scope :voting_active, -> { where(status: 'voting') }

  def voting_active?
    return false unless status == 'voting'
    return false if voting_start_date.nil? || voting_end_date.nil?
    voting_start_date <= Date.current && voting_end_date >= Date.current
  end

  def total_allocated
    budget_projects.where(status: 'approved').sum(:allocated_amount)
  end

  def remaining_funds
    total_funds - total_allocated
  end

  def utilization_percentage
    return 0 if total_funds.zero?
    (total_allocated / total_funds * 100).round(2)
  end

  def current_phase
    voting_phases.where('start_date <= ? AND end_date >= ?', Time.current, Time.current).first
  end

  def active_phase
    voting_phases.where(active: true).first
  end

  def total_votes_cast
    votes.count
  end

  def participating_users_count
    votes.distinct.count(:user_id)
  end

  # Enhancement 1: Category limit checking
  def category_within_limit?(category, additional_amount = 0)
    return true if category.spending_limit_percentage >= 100
    
    current_allocation = budget_projects
                        .where(budget_category: category, status: 'approved')
                        .sum(:allocated_amount)
    
    total_proposed = current_allocation + additional_amount
    limit_amount = (total_funds * category.spending_limit_percentage / 100)
    
    total_proposed <= limit_amount
  end

  def category_utilization_amount(category)
    budget_projects
      .where(budget_category: category, status: 'approved')
      .sum(:allocated_amount)
  end

  def category_limit_amount(category)
    total_funds * category.spending_limit_percentage / 100
  end

  # Allowlist searchable attributes for Ransack (ActiveAdmin filters)
  def self.ransackable_attributes(auth_object = nil)
    [
      "id",
      "name",
      "description",
      "status",
      "total_funds",
      "active",
      "voting_start_date",
      "voting_end_date",
      "created_at",
      "updated_at"
    ]
  end

  # Allowlist searchable associations for Ransack (ActiveAdmin filters)
  def self.ransackable_associations(auth_object = nil)
    [
      "budget_categories",
      "budget_projects",
      "votes",
      "voting_phases"
    ]
  end
end 