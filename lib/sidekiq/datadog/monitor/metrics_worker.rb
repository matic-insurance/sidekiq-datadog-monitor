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
          send_metrics(statsd)
          statsd.close
        end

        private

        def send_metrics(statsd)
          Sidekiq::Stats.new.queues.each_pair do |queue_name, size|
            post_queue_size(statsd, queue_name, size)

            post_queue_latency(statsd, queue_name)
          end
          post_scheduled_size(statsd)
        end

        def post_queue_size(statsd, queue_name, size)
          statsd.gauge('sidekiq.queue.size', size,
                       tags: ["queue_name:#{queue_name}"].concat(Data.tags))
        end

        def post_queue_latency(statsd, queue_name)
          latency = Sidekiq::Queue.new(queue_name).latency
          statsd.gauge('sidekiq.queue.latency', latency,
                       tags: ["queue_name:#{queue_name}"].concat(Data.tags))
        end

        def post_scheduled_size(statsd)
          scheduled_size = Sidekiq::Stats.new.scheduled_size
          statsd.gauge('sidekiq.scheduled', scheduled_size,
                       tags: ['scheduled_size'].concat(Data.tags))
        end
      end
    end
  end
end
