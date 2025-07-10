class BudgetProject < ApplicationRecord
  belongs_to :budget
  belongs_to :budget_category
  belongs_to :voting_phase, optional: true
  belongs_to :user # Project creator
  has_many :votes, dependent: :destroy
  has_many :voters, through: :votes, source: :user
  has_one :impact_metric, dependent: :destroy

  # Delegate impact metric methods
  delegate :overall_impact_score, :impact_category, :cost_per_beneficiary,
           :estimated_beneficiaries, :sustainability_score, :impact_summary,
           to: :impact_metric, allow_nil: true

  # Validations
  validates :title, presence: true
  validates :description, presence: true
  validates :requested_amount, presence: true, numericality: { greater_than_or_equal_to: 0.01 }
  validates :status, inclusion: { in: %w[pending approved rejected implemented] }
  validate :category_spending_limit_check, if: :approved_and_amount_changed?
  validate :voting_phase_belongs_to_budget

  accepts_nested_attributes_for :impact_metric, allow_destroy: true

  # Scopes
  scope :approved, -> { where(status: 'approved') }
  scope :pending, -> { where(status: 'pending') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :implemented, -> { where(status: 'implemented') }
  scope :by_votes_desc, -> { order(votes_count: :desc) }
  scope :by_amount_desc, -> { order(requested_amount: :desc) }
  scope :in_current_phase, -> { joins(:voting_phase).merge(VotingPhase.current) }
  # Enhancement 3: Impact-based filtering scopes
  scope :by_impact_score, -> { joins(:impact_metric).order('impact_metrics.estimated_beneficiaries DESC') }
  scope :by_sustainability, -> { joins(:impact_metric).order('impact_metrics.sustainability_score DESC') }
  scope :by_cost_effectiveness, -> { joins(:impact_metric).order('impact_metrics.cost_per_beneficiary ASC') }
  scope :high_impact, -> { joins(:impact_metric).where('impact_metrics.sustainability_score >= ? AND impact_metrics.estimated_beneficiaries >= ?', 7, 100) }

  after_create :build_default_impact_metric
  after_update :update_votes_count_cache

  # --- Voting and Approval Logic ---
  def can_vote?(user)
    return false unless budget.voting_active?
    return false unless votable_in_current_phase?
    return false if user.voted_for_project?(self)
    user.can_vote_for_project?(self)
  end

  def votable_in_current_phase?
    return true unless voting_phase # Projects without phases can be voted on anytime
    voting_phase.currently_active?
  end

  def vote_by_user(user)
    votes.find_by(user: user)
  end

  def voted_by?(user)
    votes.exists?(user: user)
  end

  def approval_percentage
    return 0 if budget.total_votes_cast.zero?
    (votes_count.to_f / budget.total_votes_cast * 100).round(2)
  end

  def funding_percentage
    return 0 if requested_amount.zero?
    (allocated_amount / requested_amount * 100).round(2)
  end

  def fully_funded?
    allocated_amount >= requested_amount
  end

  def can_be_approved?
    status == 'pending' && 
    budget.category_within_limit?(budget_category, requested_amount)
  end

  # Refactored: Use service object for approval
  def approve_with_allocation!(amount = nil)
    BudgetProjectApprovalService.new(self, amount).approve!
  end

  def reject_with_reason!(reason = nil)
    update!(
      status: 'rejected',
      justification: reason.present? ? "#{justification}\n\nRejection reason: #{reason}" : justification
    )
  end

  # Category limit checking for Enhancement 1
  def would_exceed_category_limit?(amount = nil)
    check_amount = amount || requested_amount
    !budget.category_within_limit?(budget_category, check_amount)
  end

  def category_utilization_after_approval
    return budget_category.utilization_percent unless status == 'pending'
    if budget.category_within_limit?(budget_category, requested_amount)
      current_allocation = budget_category.total_allocated
      new_total = current_allocation + requested_amount
      limit = budget_category.limit_amount
      (new_total / limit * 100).round(2)
    else
      100 # Would exceed limit
    end
  end

  # Allowlist searchable attributes for Ransack (ActiveAdmin filters)
  def self.ransackable_attributes(auth_object = nil)
    [
      "id",
      "title",
      "description",
      "budget_id",
      "budget_category_id",
      "voting_phase_id",
      "user_id",
      "requested_amount",
      "allocated_amount",
      "justification",
      "status",
      "votes_count",
      "created_at",
      "updated_at"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    [
      "budget",
      "budget_category",
      "impact_metric",
      "user",
      "voters",
      "votes",
      "voting_phase"
    ]
  end

  private

  def build_default_impact_metric
    return if impact_metric.present?
    create_impact_metric(
      estimated_beneficiaries: 0,
      sustainability_score: 5,
      timeline: '6-12 months'
    )
  end

  def update_votes_count_cache
    self.update_column(:votes_count, votes.count) if saved_change_to_votes_count?
  end

  def approved_and_amount_changed?
    status == 'approved' && (will_save_change_to_allocated_amount? || will_save_change_to_status?)
  end

  def category_spending_limit_check
    return unless budget_category && allocated_amount
    unless budget.category_within_limit?(budget_category, allocated_amount)
      errors.add(:allocated_amount, "would exceed category spending limit of #{budget_category.spending_limit_percentage}%")
    end
  end

  def voting_phase_belongs_to_budget
    return unless voting_phase && budget
    unless voting_phase.budget == budget
      errors.add(:voting_phase, "must belong to the same budget")
    end
  end
end 