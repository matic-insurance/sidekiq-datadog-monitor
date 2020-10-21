require 'datadog/statsd'
require 'sidekiq/datadog/monitor/metrics_worker'
module Sidekiq
  module Datadog
    module Monitor
      class Data
        class << self
          attr_reader :agent_port, :agent_host, :tag, :env, :queue, :cron

          def initialize!(options)
            @agent_port = options[:agent_port]
            @agent_host = options[:agent_host]
            @tag = options[:tag] || ''
            @env = options[:env] || ''
            @queue = options[:queue] || ''
            @cron = options[:cron] || "*/1 * * * *"

            start
          end

          def start
            Sidekiq.set_schedule('send_metrics', 
              { "cron"=> cron, 'class' => 'Sidekiq::Datadog::Monitor::MetricsWorker', 'queue' => queue })
          end
        end 
      end
    end
  end
end
