require "sidekiq/datadog/monitor/data"
require 'datadog/statsd'

module Sidekiq
  module Datadog
    module Monitor
      class MetricsWorker
        include Sidekiq::Worker

        sidekiq_options retry: false
        
        def perform
          Sidekiq::Stats.new.queues.each_pair do |queue_name, size|
            post_queue_size(queue_name, size)

            post_queue_latency(queue_name)
          end
        end

        private

        def statsd
          @statsd = ::Datadog::Statsd.new(Data.agent_host, Data.agent_port)
        end

        def post_queue_size(queue_name, size)
          statsd.gauge('sidekiq.queue.size', size,
                      tags: ["queue_name:#{queue_name}"].concat(Data.tags))
        end

        def post_queue_latency(queue_name)
          latency = Sidekiq::Queue.new(queue_name).latency
          statsd.gauge('sidekiq.queue.latency', latency,
                      tags: ["queue_name:#{queue_name}"].concat(Data.tags))
        end
      end
    end
  end
end
