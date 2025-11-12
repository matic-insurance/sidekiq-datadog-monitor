RSpec.describe Sidekiq::Datadog::Monitor::MetricsSender do
  let(:sender) { described_class.new(statsd, Sidekiq::Datadog::Monitor::TagBuilder.new(['env:production'])) }
  let(:statsd) { instance_double(Datadog::Statsd, gauge: true, close: true) }
  let(:stats) { instance_double(Sidekiq::Stats, scheduled_size: 123, queues: queues) }
  let(:stats_queue) { instance_double(Sidekiq::Queue, latency: 5000) }
  let(:process_set) { instance_double(Sidekiq::ProcessSet) }
  let(:dead_set) { instance_double(Sidekiq::DeadSet, size: 50) }
  let(:process1) { Sidekiq::Process.new({ 'busy' => 8, 'concurrency' => 20, 'identity' => '123' }) }
  let(:process2) { Sidekiq::Process.new({ 'busy' => 20, 'concurrency' => 20, 'identity' => '234', 'tag' => 'busy' }) }

  let(:queues) do
    [
      instance_double(Sidekiq::Queue, name: 'default', size: 100, latency: 5000),
      instance_double(Sidekiq::Queue, name: 'low', size: 25, latency: 2000)
    ]
  end

  before do
    allow(Sidekiq::Stats).to receive(:new).and_return(stats)
    allow(Sidekiq::Queue).to receive(:all).and_return(queues)
    allow(Sidekiq::ProcessSet).to receive(:new).and_return(process_set)
    allow(Sidekiq::DeadSet).to receive(:new).and_return(dead_set)

    allow(stats).to receive(:queues).and_return(queues)
    allow(statsd).to receive(:gauge)
    allow(process_set).to receive(:each).and_yield(process1).and_yield(process2)

    sender.send_metrics
  end

  it 'posts queue size' do
    expect(statsd).to have_received(:gauge).with('sidekiq.queue.size', 100, { tags: %w[queue_name:default env:production] })
    expect(statsd).to have_received(:gauge).with('sidekiq.queue.size', 25, { tags: %w[queue_name:low env:production] })
  end

  it 'posts queue latency' do
    expect(statsd).to have_received(:gauge).with('sidekiq.queue.latency', 5000, { tags: %w[queue_name:default env:production] })
    expect(statsd).to have_received(:gauge).with('sidekiq.queue.latency', 2000, { tags: %w[queue_name:low env:production] })
  end

  it 'posts process utilization' do
    metric = 'sidekiq.process.utilization'
    expect(statsd).to have_received(:gauge).with(metric, 40.0, { tags: %w[process_id:123 env:production] })
    expect(statsd).to have_received(:gauge).with(metric, 100.0, { tags: %w[process_id:234 process_tag:busy env:production] })
  end

  it 'posts scheduled size' do
    expect(statsd).to have_received(:gauge).with('sidekiq.scheduled.size', 123, { tags: %w[env:production] })
  end

  it 'posts dead set size' do
    expect(statsd).to have_received(:gauge).with('sidekiq.dead_set.size', 50, { tags: %w[env:production] })
  end
end
