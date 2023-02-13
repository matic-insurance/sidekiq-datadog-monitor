
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'sidekiq/datadog/monitor/version'

Gem::Specification.new do |spec|
  spec.name          = "sidekiq-datadog-monitor"
  spec.version       = Sidekiq::Datadog::Monitor::VERSION
  spec.authors       = ["aleksa_castle"]
  spec.email         = ["oleksandra.k@matic.com"]

  spec.summary       = %q{A gem to gather and send sidekiq jobs metrics to datadog}
  spec.license       = "MIT"
  spec.homepage      = 'https://github.com/matic-insurance/sidekiq-datadog-monitor'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files        = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.85.0"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rspec", "~> 1.38.1"

  spec.add_dependency 'sidekiq', '>= 2.2.1'
  spec.add_dependency 'dogstatsd-ruby', '~> 5.0'
end
