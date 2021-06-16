# Sidekiq::Datadog::Monitor

Library that gather sidekiq jobs metrics (currently, only size and latency)
and send it to datadog

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq-datadog-monitor'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq-datadog-monitor

## Usage

To start sending metrics

```ruby
# Import the library
require 'sidekiq/datadog/monitor/data'

# Initiate a Sidekiq::Datadog::Monitor client instance.
Sidekiq::Datadog::Monitor::Data.initialize!(
  agent_host: 'localhost',
  agent_port: 8125,
  queue: 'queue name',
  tags: ['env:production', 'product:product_name'], # optional
  cron: "*/30 * * * *" # default: "*/1 * * * *",
  batch: false # optional, default: false
)
```
`agent_host` and `agent_port` instantiate DogStatsD client

`queue` setting for background job that will gather and send Sidekiq metrics

`tags` tags for datadog metrics

`cron` - schedule settings for background job that will gather and send Sidekiq metrics

`batch` turns on sending DD metrics in batches. Make sure you don't have too many queues before enabling this option. The message with all tags must fit into [8KB of default DataDog buffer](https://docs.datadoghq.com/developers/dogstatsd/high_throughput/#enable-buffering-on-your-client) size.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sidekiq-datadog-monitor. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sidekiq::Datadog::Monitor project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/sidekiq-datadog-monitor/blob/master/CODE_OF_CONDUCT.md).
