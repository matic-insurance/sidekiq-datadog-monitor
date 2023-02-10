module Sidekiq
  module Datadog
    module Monitor
      class MetricsWorker
        include Sidekiq::Worker

        sidekiq_options retry: false

        def perform
          Sidekiq::Datadog::Monitor::MetricsSender.new.call
        end
      end
    end
  end
end
