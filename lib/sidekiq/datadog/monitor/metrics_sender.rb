require 'sidekiq/api'

module Sidekiq
  module Datadog
    module Monitor
      class MetricsSender
        attr_reader :statsd, :tags_builder
        def initialize(statsd, tags_builder)
          @statsd = statsd
          @tags_builder = tags_builder
        end

        def send_metrics
          Sidekiq::Stats.new.queues.each_pair do |queue_name, size|
            post_queue_stats(statsd, queue_name, size)
          end
          Sidekiq::ProcessSet.new.each do |process|
            post_process_stats(process)
          end
        end

        protected

        def post_queue_stats(statsd, queue_name, size)
          latency = Sidekiq::Queue.new(queue_name).latency
          tags = tags_builder.build(queue_name: queue_name)

          statsd.gauge('sidekiq.queue.size', size, tags: tags)
          statsd.gauge('sidekiq.queue.latency', latency, tags: tags)
        end

        def post_process_stats(process)
          utilization = process['busy'] / process['concurrency'].to_f
          tags = tags_builder.build(process_id: process['identity'], process_tag: process['tag'])

          statsd.gauge('sidekiq.process.utilization', utilization, tags: tags)
        end
      end
    end
  end
end
