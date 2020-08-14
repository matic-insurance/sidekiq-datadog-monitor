require "sidekiq/datadog/monitor"

module Sidekiq
  module Datadog
    module Monitor
      class Data
        class << self
          attr_reader :agent_port, :agent_host, :tag, :env, :queue, :cron

          def initialize!(options)
            @agent_port, @agent_host = options.fetch_values(:agent_port, :agent_host)
            @tag = options[:tag] || ''
            @env = options[:env] || ''
            @queue = options[:queue] || ''
            @cron = options[:cron] || "*/1 * * * *"

            start

            SidekiqScheduler::Scheduler.instance.reload_schedule!

          rescue StandardError => e
            raise Sidekiq::Datadog::Monitor::Error.new(e.message)
          end

          private

          def start
            Sidekiq.set_schedule('send_metrics', 
              { "cron"=> cron, 'class' => 'Sidekiq::Datadog::Monitor::MetricsWorker', 'queue' => queue })
          end
        end 
      end
    end
  end
end
