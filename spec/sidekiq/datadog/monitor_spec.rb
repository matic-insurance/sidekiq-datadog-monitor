RSpec.describe Sidekiq::Datadog::Monitor do
  it 'has a version number' do
    expect(Sidekiq::Datadog::Monitor::VERSION).not_to be nil
  end

  describe '.configuration!' do
    context 'when configuration valid' do
      before do
        described_class.configure!({ agent_host: 'host', agent_port: 'port', tags: ['test: true'] })
      end

      it 'adds startup listeners' do
        allow(described_class).to receive(:initialize!)
        sidekiq_config.listeners[:startup].call
        expect(described_class).to have_received(:initialize!)
      end

      it 'adds heartbeat listeners' do
        allow(described_class).to receive(:send_metrics)
        sidekiq_config.listeners[:heartbeat].call
        expect(described_class).to have_received(:send_metrics)
      end

      it 'adds shutdown listeners' do
        allow(described_class).to receive(:shutdown!)
        sidekiq_config.listeners[:shutdown].call
        expect(described_class).to have_received(:shutdown!)
      end

      it 'saves tags' do
        expect(described_class.tags_builder.build({})).to eq(['test: true'])
      end
    end

    context 'with new sidekiq' do
      before do
        sidekiq_config.options[:lifecycle_events][:beat] = []
        described_class.configure!({ agent_host: 'host', agent_port: 'port', tags: ['test: true'] })
      end

      it 'adds beat listener' do
        allow(described_class).to receive(:send_metrics)
        sidekiq_config.listeners[:beat].call
        expect(described_class).to have_received(:send_metrics)
      end

      it 'not adds heartbeat' do
        expect(sidekiq_config.listeners[:heartbeat]).to be_nil
      end
    end

    context 'when configuration is invalid' do
      it 'raises error' do
        expect { described_class.configure!({ agent_host: 'host' }) }.to raise_error(described_class::Error)
      end

      it 'not adding listeners' do
        described_class.configure!({ agent_host: 'host' })
      rescue => _
        # ignored
      ensure
        expect(sidekiq_config.listeners).to be_empty
      end
    end
  end

  describe '.initialize!' do
    let(:statsd) { instance_double(::Datadog::Statsd) }

    before do
      allow(::Datadog::Statsd).to receive(:new).and_return statsd
      described_class.configure!({ agent_host: 'host', agent_port: 'port', tags: ['test: true'] })
      described_class.initialize!
    end

    it 'creates statsd instance' do
      expect(::Datadog::Statsd).to have_received(:new).with('host', 'port')
      expect(described_class.statsd).to eq(statsd)
    end

    it 'creates metrics sender' do
      expect(described_class.sender).to be_instance_of(described_class::MetricsSender)
    end
  end

  describe '.send_metrics!' do
    before do
      described_class.configure!({ agent_host: 'host', agent_port: 'port', tags: ['test: true'] })
      described_class.initialize!
    end

    it 'sends metrics' do
      allow(described_class.sender).to receive(:send_metrics)
      described_class.send_metrics
      expect(described_class.sender).to have_received(:send_metrics)
    end
  end

  describe '.shutdown!' do
    let(:statsd) { instance_double(::Datadog::Statsd, close: true) }

    before do
      allow(::Datadog::Statsd).to receive(:new).and_return statsd
      described_class.configure!({ agent_host: 'host', agent_port: 'port', tags: ['test: true'] })
      described_class.initialize!
      described_class.shutdown!
    end

    it 'creates statsd instance' do
      expect(statsd).to have_received(:close)
      expect(described_class.statsd).to eq(statsd)
    end
  end
end
