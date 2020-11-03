require 'pry'
module Sidekiq
  module Datadog
    module Monitor
      class Data
        class << self
          attr_reader :agent_port, :agent_host, :tags, :env, :queue, :cron

          def initialize!(options)
            @agent_port, @agent_host, @queue = options.fetch_values(:agent_port, :agent_host, :queue)
            @tags = options[:tags] || []
            @cron = options[:cron] || "*/1 * * * *"

          Sidekiq.configure_server do |config|
            binding.pry
            SidekiqScheduler::Scheduler.dynamic = true

            config.on(:startup) do
              start
            end
          end

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
