class VotingPhase < ApplicationRecord
  belongs_to :budget
  has_many :budget_projects, dependent: :nullify
  has_many :votes, dependent: :destroy

  validates :name, presence: true
  validates :start_date, :end_date, presence: true
  validate :end_date_after_start_date
  validate :no_overlapping_phases_in_budget

  scope :ordered, -> { order(:position, :start_date) }
  scope :active, -> { where(active: true) }
  scope :current, -> { where('start_date <= ? AND end_date >= ?', Time.current, Time.current) }

  serialize :rules, coder: JSON

  before_save :ensure_single_active_phase_per_budget

  # Enhancement 2: Multi-phase voting methods
  def currently_active?
    active? && Time.current.between?(start_date, end_date)
  end

  def upcoming?
    start_date > Time.current
  end

  def completed?
    end_date < Time.current
  end

  def status
    return 'completed' if completed?
    return 'active' if currently_active?
    return 'upcoming' if upcoming?
    'inactive'
  end

  def duration_in_days
    (end_date.to_date - start_date.to_date).to_i + 1
  end

  def votes_cast_count
    votes.count
  end

  def participating_users_count
    votes.distinct.count(:user_id)
  end

  def projects_count
    budget_projects.count
  end

  def can_vote?(user)
    return false unless currently_active?
    
    user_votes_in_phase = votes.where(user: user).count
    user_votes_in_phase < max_votes_per_user
  end

  def votes_remaining_for_user(user)
    return 0 unless currently_active?
    
    user_votes_in_phase = votes.where(user: user).count
    [max_votes_per_user - user_votes_in_phase, 0].max
  end

  # Auto-transition logic
  def self.check_and_transition_phases
    # Deactivate completed phases
    active.where('end_date < ?', Time.current).update_all(active: false)
    
    # Activate phases that should be active now
    Budget.includes(:voting_phases).find_each do |budget|
      current_phase = budget.voting_phases.current.first
      if current_phase && !current_phase.active?
        # Deactivate other phases in this budget
        budget.voting_phases.where(active: true).update_all(active: false)
        # Activate current phase
        current_phase.update(active: true)
      end
    end
  end

  def phase_rules
    @phase_rules ||= (rules.presence || {}).with_indifferent_access
  end

  def get_rule(key, default = nil)
    phase_rules[key] || default
  end

  def set_rule(key, value)
    self.rules = phase_rules.merge(key => value)
  end

  def self.ransackable_associations(auth_object = nil)
    ["budget", "budget_projects", "votes"]
  end

  # Allowlist searchable attributes for Ransack (ActiveAdmin filters)
  def self.ransackable_attributes(auth_object = nil)
    [
      "id",
      "name",
      "description",
      "start_date",
      "end_date",
      "active",
      "budget_id",
      "max_votes_per_user",
      "position",
      "rules",
      "created_at",
      "updated_at"
    ]
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date
    
    errors.add(:end_date, 'must be after start date') if end_date <= start_date
  end

  def no_overlapping_phases_in_budget
    return unless budget && start_date && end_date
    
    overlapping = budget.voting_phases
                        .where.not(id: id)
                        .where('(start_date <= ? AND end_date >= ?) OR (start_date <= ? AND end_date >= ?)',
                               start_date, start_date, end_date, end_date)
    
    errors.add(:base, 'Phase dates overlap with existing phase') if overlapping.exists?
  end

  def ensure_single_active_phase_per_budget
    return unless active? && budget
    
    # Deactivate other phases in the same budget
    budget.voting_phases.where.not(id: id).update_all(active: false)
  end
end 