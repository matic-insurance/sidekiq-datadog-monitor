require 'sidekiq/datadog/monitor/metrics_worker'
require "sidekiq/datadog/monitor/version"
require 'sidekiq-scheduler'
require 'datadog/statsd'
require 'sidekiq/api'
require 'sidekiq'

module Sidekiq
  module Datadog
    module Monitor 
      class Error < StandardError; end
    end
  end
end
