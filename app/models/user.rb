class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :budget_projects, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :voted_projects, through: :votes, source: :budget_project

  validates :first_name, :last_name, presence: true
  validates :available_votes, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def full_name
    "#{first_name} #{last_name}"
  end

  def votes_remaining_for_budget(budget)
    total_votes_used = votes.joins(:budget_project)
                           .where(budget_projects: { budget: budget })
                           .count
    available_votes - total_votes_used
  end

  def voted_for_project?(project)
    votes.exists?(budget_project: project)
  end

  def can_vote_for_project?(project)
    unless project.budget.voting_active?
      puts "[VOTE] User ##{id}: Budget voting is not active for project ##{project.id} (budget_id: #{project.budget_id})"
      return false
    end
    if voted_for_project?(project)
      puts "[VOTE] User ##{id}: Already voted for project ##{project.id}"
      return false
    end
    if votes_remaining_for_budget(project.budget) <= 0
      puts "[VOTE] User ##{id}: No votes remaining for budget ##{project.budget_id}"
      return false
    end
    if project.voting_phase&.active?
      phase_votes = votes.where(voting_phase: project.voting_phase).count
      if phase_votes >= project.voting_phase.max_votes_per_user
        puts "[VOTE] User ##{id}: Phase vote limit reached for phase ##{project.voting_phase.id}"
        return false
      end
    end
    puts "[VOTE] User ##{id}: Can vote for project ##{project.id}"
    true
  end
end 