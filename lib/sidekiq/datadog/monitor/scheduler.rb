require 'sidekiq'
require 'datadog/statsd'
module Sidekiq
  module Datadog
    module Monitor
      class Scheduler
        include Sidekiq::Worker
        sidekiq_options retry: false, queue: 'critical'

        def call
          return unless settings.enabled

          Sidekiq::Stats.new.queues.each_pair do |queue_name, size|
            post_queue_size(queue_name, size)

            post_queue_latency(queue_name)
          end
        end

        private

        def statsd
          @statsd = Datadog::Statsd.new(settings.agent_host, settings.agent_port)
        end

        def post_queue_size(queue_name, size)
          statsd.gauge('sidekiq.queue.size', size,
                      tags: ["queue_name:#{queue_name}", "environment:#{env}", product])
        end

        def post_queue_latency(queue_name)
          latency = Sidekiq::Queue.new(queue_name).latency
          statsd.gauge('sidekiq.queue.latency', latency,
                      tags: ["queue_name:#{queue_name}", "environment:#{env}", product])
        end

        def settings
          Settings.integrations.datadog
        end

        def env
          settings.environment
        end

        def product
          product = Settings.product.lowcase
          "product:#{product}"
        end
      end
    end
  end
end