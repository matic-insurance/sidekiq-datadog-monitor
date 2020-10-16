
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sidekiq/datadog/monitor/version"
require "sidekiq/datadog/monitor/metrics_worker"
require "sidekiq/datadog/monitor/data"

Gem::Specification.new do |spec|
  spec.name          = "sidekiq-datadog-monitor"
  spec.version       = Sidekiq::Datadog::Monitor::VERSION
  spec.authors       = ["aleksa_castle"]
  spec.email         = ["oleksandra.k@matic.com"]

  spec.summary       = %q{A gem to gather and send sidekiq jobs metrics to datadog}
  spec.license       = "MIT"

  spec.files        = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_dependency "sidekiq", ">= 2.2.1"
  spec.add_dependency "dogstatsd-ruby"
end
