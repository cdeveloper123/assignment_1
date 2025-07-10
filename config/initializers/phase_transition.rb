# Start the phase transition job when the application starts
# This will check for phase transitions every hour

Rails.application.config.after_initialize do
  if (Rails.env.production? || Rails.env.development?) && ENV['ENABLE_BACKGROUND_JOBS']
    PhaseTransitionJob.perform_later
  end
end 