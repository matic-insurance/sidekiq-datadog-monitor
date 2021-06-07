require 'sidekiq/datadog/monitor/data'
require 'datadog/statsd'

module Sidekiq
  module Datadog
    module Monitor
      class MetricsWorker
        include Sidekiq::Worker

        sidekiq_options retry: false

        def perform
          statsd = ::Datadog::Statsd.new(Data.agent_host, Data.agent_port)

          return send_metrics(statsd) unless Data.batch

          statsd.batch { |batch_statsd| send_metrics(batch_statsd) }
        end

        private

        def send_metrics(statsd)
          Stats.new.queues.each_pair do |queue_name, size|
            post_queue_size(statsd, queue_name, size)

            post_queue_latency(statsd, queue_name)
          end
        end

        def post_queue_size(statsd, queue_name, size)
          statsd.gauge('sidekiq.queue.size', size,
                       tags: ["queue_name:#{queue_name}"].concat(Data.tags))
        end

        def post_queue_latency(statsd, queue_name)
          latency = Queue.new(queue_name).latency
          statsd.gauge('sidekiq.queue.latency', latency,
                       tags: ["queue_name:#{queue_name}"].concat(Data.tags))
        end
      end
    end
  end
end
