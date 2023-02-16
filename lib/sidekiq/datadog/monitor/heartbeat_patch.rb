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
          def apply_heartbeat_patch
            require 'sidekiq/launcher'

            Sidekiq::Launcher.prepend(Sidekiq::Datadog::Monitor::HeartbeatPatch)
            Sidekiq[:lifecycle_events][:beat] ||= []
          end

          def needs_patching?
            return false unless Sidekiq[:lifecycle_events] # No events exist, Sidekiq is too old
            return false if Sidekiq[:lifecycle_events][:beat] # beat event exist - no need to patch

            true
          end
        end
      end
    end
  end
end