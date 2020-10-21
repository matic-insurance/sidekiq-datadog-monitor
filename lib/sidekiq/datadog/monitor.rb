require 'sidekiq-scheduler'
require 'sidekiq/api'
require "sidekiq/datadog/monitor/data"
require 'sidekiq/datadog/monitor/metrics_worker'

module Sidekiq
  module Datadog
    module Monitor
      class Error < StandardError; end
    end
  end
end
