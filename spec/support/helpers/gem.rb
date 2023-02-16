module Helpers
  module Gem
    def sidekiq_config
      @sidekiq_config ||= SidekiqConfigDouble.new
    end
  end

  class SidekiqConfigDouble
    attr_reader :listeners, :options

    def initialize
      reset!
    end

    def on(event, &block)
      listeners[event] = block
    end

    def reset!
      @listeners = {}
      @options = { lifecycle_events: {} }
    end
  end
end

RSpec.configure do |config|
  config.include(Helpers::Gem)

  config.before(:each) do
    allow(Sidekiq).to receive(:configure_server).and_yield(sidekiq_config)
  end

  config.after(:each) do
    Sidekiq::Datadog::Monitor.send(:reset!)
    sidekiq_config.reset!
  end
end
