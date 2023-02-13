require 'sidekiq/api'

module Sidekiq
  module Datadog
    module Monitor
      class MetricsSender
        attr_reader :statsd, :common_tags
        def initialize(statsd, common_tags)
          @statsd = statsd
          @common_tags = common_tags
        end

        def send_metrics
          Sidekiq::Stats.new.queues.each_pair do |queue_name, size|
            post_queue_size(statsd, queue_name, size)
            post_queue_latency(statsd, queue_name)
          end
        end

        protected

        def post_queue_size(statsd, queue_name, size)
          statsd.gauge('sidekiq.queue.size', size,
                       tags: ["queue_name:#{queue_name}"].concat(common_tags))
        end

        def post_queue_latency(statsd, queue_name)
          latency = Sidekiq::Queue.new(queue_name).latency
          statsd.gauge('sidekiq.queue.latency', latency,
                       tags: ["queue_name:#{queue_name}"].concat(common_tags))
        end
      end
    end
  end
end
