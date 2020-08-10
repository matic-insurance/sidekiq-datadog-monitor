
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sidekiq/datadog/monitor/version"

Gem::Specification.new do |spec|
  spec.name          = "sidekiq-datadog-monitor"
  spec.version       = Sidekiq::Datadog::Monitor::VERSION
  spec.authors       = ["TODO: Write your name"]
  spec.email         = ["56920003+oleksandra-k@users.noreply.github.com"]

  spec.summary       = %q{A gem to gather and send sidekiq jobs metrics to datadog}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
