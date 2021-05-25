RSpec.describe Sidekiq::Datadog::Monitor::Data do
  subject(:initialize!) { described_class.initialize!(options) }

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
      queue: 'queue_name',
      cron: '*/30 * * * *',
      batch: batch
    }
  end

  let(:worker_options) do
    { 'class' => 'Sidekiq::Datadog::Monitor::MetricsWorker',
      'cron' => '*/30 * * * *',
      'queue' => 'critical' }
  end

  let(:batch) { true }
  let(:instance) { SidekiqScheduler::Scheduler.new(scheduler_options) }

  context 'when options are provided' do
    before { initialize! }

    it { expect(described_class.cron).to eql(options[:cron]) }
    it { expect(described_class.queue).to eql(options[:queue]) }
    it { expect(described_class.agent_host).to eql(options[:agent_host]) }
    it { expect(described_class.agent_port).to eql(options[:agent_port]) }
    it { expect(described_class.tags).to eql(options[:tags]) }

    context 'when `batch` option is false' do
      let(:batch) { false }

      it { expect(described_class.batch).to be false }
    end

    context 'when `batch` option is false' do
      let(:batch) { true }

      it { expect(described_class.batch).to be true }
    end
  end

  context 'when options are not provided' do
    context 'mandatory' do
      let(:options) { { tags: ['tag:tag', 'env:production'], cron: '*/30 * * * *' } }

      it 'raise error' do
        expect { initialize! }.to raise_error(Sidekiq::Datadog::Monitor::Error)
      end
    end

    context 'optional' do
      let(:options) { { agent_host: 'local', agent_port: 8125, queue: 'critical' } }

      before { initialize! }

      it 'cron has default' do
        expect(described_class.cron).to eql('*/1 * * * *')
      end

      it 'tags is empty string' do
        expect(described_class.tags).to eql([])
      end

      it 'batch is false' do
        expect(described_class.batch).to be false
      end
    end

    context 'when the server is launched' do
      before { allow(Sidekiq).to receive(:server?).and_return true }

      it 'sets a startup hook and a dynamic scheduler' do
        expect { initialize! }
          .to change { Sidekiq.options[:lifecycle_events][:startup] }
          .from([])
          .to([an_instance_of(Proc)])
          .and change { SidekiqScheduler::Scheduler.dynamic }
          .from(nil)
          .to(true)
      end

      context 'on startup' do
        let(:helper) { Class.new { include Sidekiq::Util }.new }

        before do
          allow(Sidekiq)
            .to receive(:set_schedule)
            .with('send_metrics',
                  'cron' => '*/30 * * * *',
                  'class' => 'Sidekiq::Datadog::Monitor::MetricsWorker',
                  'queue' => 'queue_name')
            .and_return(true)
        end

        it 'sets a schedule' do
          expect(Sidekiq)
            .to receive(:set_schedule)
            .with('send_metrics',
                  'cron' => '*/30 * * * *',
                  'class' => 'Sidekiq::Datadog::Monitor::MetricsWorker',
                  'queue' => 'queue_name')

          helper.fire_event(:startup)
        end
      end
    end

    context 'when initializer raises an error' do
      let(:message) { 'Error Message' }

      before do
        allow(Sidekiq)
          .to receive(:configure_server)
          .and_raise Class.new(StandardError), message
      end

      it 're-raises Datadog::Monitor::Error' do
        expect { initialize! }
          .to raise_error(Sidekiq::Datadog::Monitor::Error, message)
      end
    end
  end
end
