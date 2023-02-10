require 'datadog/statsd'

module Sidekiq
  module Datadog
    module Monitor
      class MetricsSender
        def call
          statsd = ::Datadog::Statsd.new(Data.agent_host, Data.agent_port)
          Sidekiq::Stats.new.queues.each_pair do |queue_name, size|
            post_queue_size(statsd, queue_name, size)

            post_queue_latency(statsd, queue_name)
          end
          statsd.close
        end

        protected

        def post_queue_size(statsd, queue_name, size)
          statsd.gauge('sidekiq.queue.size', size,
                       tags: ["queue_name:#{queue_name}"].concat(Data.tags))
        end

        def post_queue_latency(statsd, queue_name)
          latency = Sidekiq::Queue.new(queue_name).latency
          statsd.gauge('sidekiq.queue.latency', latency,
                       tags: ["queue_name:#{queue_name}"].concat(Data.tags))
        end

      end
    end
  end
end