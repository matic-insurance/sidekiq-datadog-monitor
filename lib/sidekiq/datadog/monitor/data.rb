module Sidekiq
  module Datadog
    module Monitor
      class Data
        class << self
          attr_reader :agent_port, :agent_host, :tags, :env, :queue, :cron, :batch

          def initialize!(options)
            @agent_port, @agent_host, @queue = options.fetch_values(:agent_port, :agent_host, :queue)
            @tags = options[:tags] || []
            @cron = options[:cron] || '*/1 * * * *'
            @batch = options[:batch] || false

            Sidekiq.configure_server do |config|
              # Since Sidekiq::Scheduler = SidekiqScheduler::Scheduler
              Scheduler.dynamic = true

              config.on(:startup) do
                start
              end
            end
          rescue StandardError => e
            raise Error, e
          end

          private

          def start
            Sidekiq.set_schedule('send_metrics',
                                 { 'cron' => cron, 'class' => 'Sidekiq::Datadog::Monitor::MetricsWorker', 'queue' => queue })
          end
        end
      end
    end
  end
end
