RSpec.describe Sidekiq::Datadog::Monitor::TagBuilder do
  let(:builder) { described_class.new(%w[tag:tag environment:production]) }

  describe '#build' do
    context 'without tags' do
      it 'returns common tags' do
        expect(builder.build({})).to eq(%w[tag:tag environment:production])
      end
    end

    context 'with empty tag value' do
      it 'returns common tags for nil' do
        expect(builder.build({ test: nil })).to eq(%w[tag:tag environment:production])
      end

      it 'returns common tags for empty string' do
        expect(builder.build({ test: '' })).to eq(%w[tag:tag environment:production])
      end
    end

    context 'with special symbols' do
      it 'replacing special symbols' do
        tags = %w[test:local_test_123_456 tag:tag environment:production]
        expect(builder.build({ test: 'local.test/123:456' })).to eq(tags)
      end
    end
  end
end
