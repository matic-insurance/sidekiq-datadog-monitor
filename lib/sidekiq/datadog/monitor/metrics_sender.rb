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
          Sidekiq::Queue.all.each do |queue|
            post_queue_stats(queue)
          end
          Sidekiq::ProcessSet.new.each do |process|
            post_process_stats(process)
          end
          post_scheduled_stats
        end

        protected

        def post_queue_stats(queue)
          tags = tags_builder.build(queue_name: queue.name)

          statsd.gauge('sidekiq.queue.size', queue.size, tags: tags)
          statsd.gauge('sidekiq.queue.latency', queue.latency, tags: tags)
        end

        def post_process_stats(process)
          utilization = (process['busy'] / process['concurrency'].to_f * 100).round(2)
          tags = tags_builder.build(process_id: process['identity'], process_tag: process['tag'])

          statsd.gauge('sidekiq.process.utilization', utilization, tags: tags)
        end

        def post_scheduled_stats
          scheduled_size = Sidekiq::Stats.new.scheduled_size
          statsd.gauge('sidekiq.scheduled.size', scheduled_size, tags: tags_builder.build({}))
        end
      end
    end
  end
end
