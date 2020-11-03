require 'pry'
RSpec.describe Sidekiq::Datadog::Monitor::Data do
  let(:scheduler_options) do
    {
      enabled: true,
      dynamic: false,
      dynamic_every: '5s',
      listened_queues_only: false
    }
  end

  let(:options) do
    {
      agent_host: 'localhost',
      agent_port: 8125,
      tags: ['tag:tag', 'env:production'],
      queue: 'queue name',
      cron: '*/30 * * * *'
    }
  end

  let(:worker_options) do
    { 'class' => 'Sidekiq::Datadog::Monitor::MetricsWorker',
      'cron' => '*/30 * * * *',
      'queue' => 'critical' }
  end

  let(:instance) { SidekiqScheduler::Scheduler.new(scheduler_options) }

  context 'when options are provided' do
    before do
      described_class.initialize!(options)
    end

    it { expect(described_class.cron).to eql(options[:cron]) }
    it { expect(described_class.queue).to eql(options[:queue]) }
    it { expect(described_class.agent_host).to eql(options[:agent_host]) }
    it { expect(described_class.agent_port).to eql(options[:agent_port]) }
    it { expect(described_class.tags).to eql(options[:tags]) }
  end
  

  context 'when options are not provided' do
    context 'mandatory' do
      let(:options) { {tags: ['tag:tag', 'env:production'], cron: '*/30 * * * *'} }

      it 'raise error' do
        expect{described_class.initialize!(options)}.to raise_error(Sidekiq::Datadog::Monitor::Error)
      end
    end

    context 'optional' do
      let(:options) { {agent_host: 'local', agent_port: 8125, queue: 'critical'} }

      before { described_class.initialize!(options) }

      it 'cron has default' do
        expect(described_class.cron).to eql("*/1 * * * *")
      end

      it 'tags is empty string' do
        expect(described_class.tags).to eql([])
      end
    end
  end
end
