module Sidekiq
  module Datadog
    module Monitor
      # Prior to Sidekiq 6.5.2 - there was no beat event that fired every couple seconds
      # Following Module wraps original heartbeat method on Sidekiq::Launcher fires :beat lifecycle event
      module HeartbeatPatch
        def heartbeat
          super
          fire_beat
        end

        def fire_beat
          return unless (listeners = Sidekiq.options[:lifecycle_events][:beat])

          listeners.each { |block| block.call }
        end

        class << self
          def apply_heartbeat_patch(sidekiq_config)
            require 'sidekiq/launcher'

            sidekiq_config.options[:lifecycle_events][:beat] ||= []
            Sidekiq::Launcher.prepend(Sidekiq::Datadog::Monitor::HeartbeatPatch)
          end

          def needs_patching?(sidekiq_config)
            return false unless sidekiq_config.respond_to?(:options) # Unsupported config version
            return false unless sidekiq_config.options[:lifecycle_events] # No events exist, Sidekiq is too old
            return false if sidekiq_config.options[:lifecycle_events][:beat] # beat event exist - no need to patch

            true
          end
        end
      end
    end
  end
end