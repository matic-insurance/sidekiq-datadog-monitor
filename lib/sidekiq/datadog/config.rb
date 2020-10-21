module Sidekiq
  module Datadog
    class Config
      class << self
        def reload_schedule
          Sidekiq.configure_server do |config|
            Sidekiq::Scheduler.dynamic = true
          end
        end
      end
    end
  end
end
