# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Enable threaded mode
# config.threadsafe!

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

config.action_controller.allow_forgery_protection    = false

SERVER_NAME = "bgtwt.com"

config.after_initialize do
  AsyncObserver::Queue.queue = Beanstalk::Pool.new(%w(localhost:11300))

  # This value should change every time you make a release of your app.
  AsyncObserver::Queue.app_version = File.read("#{RAILS_ROOT}/REVISION").hash.abs
  
end

SHOW_ADS = true


if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      AsyncObserver::Queue.queue.close
      AsyncObserver::Queue.queue.connect
    end
  end
end
