RSpec.describe Sidekiq::Datadog::Monitor::MetricsWorker do
  let(:perform) { described_class.new.perform }	
  let(:statsd) { instance_double(Datadog::Statsd, gauge: true) }	
  let(:stats) { instance_double(Sidekiq::Stats) }	
  let(:stats_queue) { instance_double(Sidekiq::Queue) }	

  let(:queues) { {'default' => 100} }	
  let(:tags) do	
    {tags: ['queue_name:default', 'env:production', 'tag']}	
  end	

  let(:options) do
      {
        agent_host: 'localhost', 
        agent_port: 8125,
        env: 'production',    
        tag: 'tag',           
        queue: 'queue name',  
        cron: "*/30 * * * *"} 
    end

 # it { is_expected.to be_processed_in :critical }	
 # it { is_expected.to be_retryable false }	
 
    before do	
      Sidekiq::Datadog::Monitor::Data.initialize!(options)
      
      allow(Sidekiq::Stats).to receive(:new).and_return(stats)	
      allow(Sidekiq::Queue).to receive(:new).with('default').and_return(stats_queue)	
      allow(stats_queue).to receive(:latency).and_return(5000)	

      allow(Datadog::Statsd).to receive(:new).and_return(statsd)	
      allow(stats).to receive(:queues).and_return(queues)	
      allow(statsd).to receive(:gauge)	

      perform	
    end	

    it 'posts queue size' do	
      expect(statsd).to have_received(:gauge).with('sidekiq.queue.size', 100, tags)	
    end	

    it 'posts queue latency' do	
      expect(statsd).to have_received(:gauge).with('sidekiq.queue.latency', 5000, tags)	
    end	
end
