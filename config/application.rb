require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module ParticipatingBudgeting
  class Application < Rails::Application
    config.load_defaults 7.0
    
    # Time zone
    config.time_zone = 'UTC'
    
    # Active Job adapter
    config.active_job.queue_adapter = :sidekiq
  end
end 