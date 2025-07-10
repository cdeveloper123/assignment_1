class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :budget_project, counter_cache: :votes_count
  belongs_to :voting_phase, optional: true

  validates :user_id, uniqueness: { scope: :budget_project_id, 
                                   message: "can only vote once per project" }
  validates :vote_weight, presence: true, 
            numericality: { greater_than: 0, less_than_or_equal_to: 10 }
  validate :user_has_votes_remaining
  validate :project_accepts_votes
  validate :phase_specific_validations

  scope :in_phase, ->(phase) { where(voting_phase: phase) }
  scope :recent, -> { order(created_at: :desc) }

  after_create :decrement_user_votes
  after_destroy :increment_user_votes

  def weighted_vote?
    vote_weight != 1.0
  end

  private

  def user_has_votes_remaining
    return unless user && budget_project
    
    unless user.can_vote_for_project?(budget_project)
      errors.add(:user, "has no remaining votes for this budget")
    end
  end

  def project_accepts_votes
    return unless budget_project
    
    unless budget_project.budget.voting_active?
      errors.add(:budget_project, "is not currently accepting votes")
    end

    unless budget_project.votable_in_current_phase?
      errors.add(:budget_project, "is not votable in the current phase")
    end
  end

  def phase_specific_validations
    return unless voting_phase && user
    
    unless voting_phase.can_vote?(user)
      errors.add(:voting_phase, "voting limit exceeded for this phase")
    end
  end

  def decrement_user_votes
    # Optional: Implement vote tracking if needed
  end

  def increment_user_votes
    # Optional: Implement vote tracking if needed
  end
end 