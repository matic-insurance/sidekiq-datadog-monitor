RSpec.describe Sidekiq::Datadog::Monitor do
  it 'has a version number' do
    expect(Sidekiq::Datadog::Monitor::VERSION).not_to be nil
  end
end
