class PhaseTransitionJob < ApplicationJob
  queue_as :default

  def perform
    VotingPhase.check_and_transition_phases
    
    # Log the transition check
    Rails.logger.info "Phase transition check completed at #{Time.current}"
    
    # Schedule next check in 1 hour
    PhaseTransitionJob.set(wait: 1.hour).perform_later
  end
end 