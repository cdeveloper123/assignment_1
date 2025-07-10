class BudgetProjectVotingService
  def initialize(project, user, params = {})
    @project = project
    @user = user
    @params = params
  end

  def vote!
    return { success: false, message: 'You cannot vote for this project.' } unless @project.can_vote?(@user)
    voting_phase = @project.voting_phase || @project.budget.current_phase
    vote = @project.votes.build(
      user: @user,
      voting_phase: voting_phase,
      vote_weight: @params[:vote_weight]&.to_f || 1.0,
      comment: @params[:comment]
    )
    if vote.save
      { success: true, message: 'Your vote has been recorded!' }
    else
      { success: false, message: vote.errors.full_messages.join(', ') }
    end
  end

  def remove_vote!
    vote = @project.votes.find_by(user: @user)
    if vote
      vote.destroy
      { success: true, message: 'Your vote has been removed.' }
    else
      { success: false, message: 'You have not voted for this project.' }
    end
  end
end 