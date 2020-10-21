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
      env: 'production',
      tag: 'tag',
      queue: 'queue name',
      cron: '*/30 * * * *'
    }
  end

  let(:worker_options) do
    { 'class' => 'Sidekiq::Datadog::Monitor::MetricsWorker',
      'cron' => '*/30 * * * *',
      'queue' => 'queue name' }
  end

  let(:instance) { SidekiqScheduler::Scheduler.new(scheduler_options) }

  context 'when options are not provided' do
    before do
      described_class.initialize!(options)
    end

    it { expect(described_class.cron).to eql(options[:cron]) }
    it { expect(described_class.queue).to eql(options[:queue]) }
    it { expect(described_class.agent_host).to eql(options[:agent_host]) }
    it { expect(described_class.agent_port).to eql(options[:agent_port]) }
    it { expect(described_class.env).to eql(options[:env]) }
    it { expect(described_class.tag).to eql(options[:tag]) }
  end
  

  context 'when options are not provided' do
    let(:options) { {} }

    context 'mandatory' do
      let(:message) { 'agent_host and agent_port must be defined' }

      it 'raise error' do
        expect{described_class.initialize!(options)}.to raise_error(Sidekiq::Datadog::Monitor::Error)
      end
    end

    context 'optional' do
      let(:options) { {agent_host: 'local', agent_port: 8125} }

      before { described_class.initialize!(options) }
      it 'cron has default' do
        expect(described_class.cron).to eql("*/1 * * * *")
      end

      it 'queue is empty string' do
        expect(described_class.queue).to eql("")
      end

      it 'tag is empty string' do
        expect(described_class.tag).to eql("")
      end

      it 'env is empty string' do
        expect(described_class.env).to eql("")
      end
    end
  end
end
