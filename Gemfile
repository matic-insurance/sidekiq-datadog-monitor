source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in sidekiq-datadog-monitor.gemspec
gemspec

group :test, :development do
  gem 'pry'
end

group :test do
  source 'https://oss:fhv24QsMiVo3h9SWfrazGUQ6tuANB7Vz@gem.mutant.dev' do
    gem 'mutant-license', '0.1.0'
  end
end
