RSpec.describe Sidekiq::Datadog::Monitor::MetricsSender do
  let(:perform) { described_class.new.call }
  let(:statsd) { instance_double(Datadog::Statsd, gauge: true, close: true) }
  let(:stats) { instance_double(Sidekiq::Stats) }
  let(:stats_queue) { instance_double(Sidekiq::Queue, latency: 5000) }

  let(:queues) { { 'default' => 100, 'low' => 25 } }
  let(:tags) { %w[tag:tag env:production] }

  let(:options) do
    {
      agent_host: 'localhost',
      agent_port: 8125,
      tags: tags,
      queue: 'critical',
      cron: '*/30 * * * *'
    }
  end

  before do
    Sidekiq::Datadog::Monitor::Data.initialize!(options)

    allow(Sidekiq::Stats).to receive(:new).and_return(stats)
    allow(Sidekiq::Queue).to receive(:new).and_return(stats_queue)

    allow(Datadog::Statsd).to receive(:new).and_return(statsd)
    allow(stats).to receive(:queues).and_return(queues)
    allow(statsd).to receive(:gauge)

    perform
  end

  it 'posts queue size' do
    expect(statsd).to have_received(:gauge).with('sidekiq.queue.size', 100, { tags: ['queue_name:default'] + tags })
    expect(statsd).to have_received(:gauge).with('sidekiq.queue.size', 25, { tags: ['queue_name:low'] + tags })
  end

  it 'posts queue latency' do
    expect(statsd).to have_received(:gauge).with('sidekiq.queue.latency', 5000, { tags: ['queue_name:default'] + tags })
    expect(statsd).to have_received(:gauge).with('sidekiq.queue.latency', 5000, { tags: ['queue_name:low'] + tags })
  end

  it 'closing statsd instance' do
    expect(statsd).to have_received(:close)
  end
end
