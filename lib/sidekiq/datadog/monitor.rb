require 'sidekiq'
require 'datadog/statsd'
require 'sidekiq/datadog/monitor/metrics_sender'
require 'sidekiq/datadog/monitor/tag_builder'
require 'sidekiq/datadog/monitor/heartbeat_patch'

module Sidekiq
  module Datadog
    module Monitor
      class Error < StandardError; end

      class << self
        attr_accessor :agent_port, :agent_host, :tags_builder, :statsd, :sender

        def configure!(options)
          raise Sidekiq::Datadog::Monitor::Error, "Can't configure two times" if configured?

          @agent_host, @agent_port = options.fetch_values(:agent_host, :agent_port)
          @tags_builder = Sidekiq::Datadog::Monitor::TagBuilder.new(options[:tags] || [])

          add_sidekiq_listeners
        rescue KeyError => e
          raise Sidekiq::Datadog::Monitor::Error, "Required param is missing: #{e.message}"
        end

        def configured?
          agent_host && agent_port
        end

        def initialize!
          @statsd = ::Datadog::Statsd.new(agent_host, agent_port)
          @sender = Sidekiq::Datadog::Monitor::MetricsSender.new(statsd, tags_builder)
        end

        def send_metrics
          sender.send_metrics
        end

        def shutdown!
          statsd.close
        end

        private

        def reset!
          @agent_host = nil
          @agent_port = nil
          @statsd = nil
          @sender = nil
        end

        def add_sidekiq_listeners
          Sidekiq.configure_server do |config|
            patch_sidekiq_heartbeat

            config.on(:startup) do
              Sidekiq::Datadog::Monitor.initialize!
            end
            config.on(:beat) do
              Sidekiq::Datadog::Monitor.send_metrics
            end
            config.on(:shutdown) do
              Sidekiq::Datadog::Monitor.shutdown!
            end
          end
        end

        def patch_sidekiq_heartbeat
          return unless Sidekiq::Datadog::Monitor::HeartbeatPatch.needs_patching?

          Sidekiq::Datadog::Monitor::HeartbeatPatch.apply_heartbeat_patch
        end
      end
    end
  end
end
