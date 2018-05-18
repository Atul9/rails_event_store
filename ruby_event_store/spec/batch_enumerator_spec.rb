require 'spec_helper'
require 'ruby_event_store/batch_enumerator'

module RubyEventStore
  RSpec.describe BatchEnumerator do
    let(:collection) { (1..10000).to_a }
    let(:reader) { ->(offset,limit) { collection.drop(offset).take(limit) } }

    specify { expect(BatchEnumerator.new(100, 900, reader).each_batch.to_a.size).to eq(9) }
    specify { expect(BatchEnumerator.new(100, 901, reader).each_batch.to_a.size).to eq(10) }
    specify { expect(BatchEnumerator.new(100, 1000, reader).each_batch.to_a.size).to eq(10) }
    specify { expect(BatchEnumerator.new(100, 1000, reader).each_batch.to_a[0].size).to eq(100) }
    specify { expect(BatchEnumerator.new(100, 1000, reader).each_batch.to_a[0]).to eq((1..100).to_a) }
    specify { expect(BatchEnumerator.new(100, 1001, reader).each_batch.to_a.size).to eq(11) }
    specify { expect(BatchEnumerator.new(100, 10, reader).each_batch.to_a.size).to eq(1) }
    specify { expect(BatchEnumerator.new(100, 10, reader).each_batch.to_a[0].size).to eq(10) }
    specify { expect(BatchEnumerator.new(100, 10, reader).each_batch.to_a[0]).to eq((1..10).to_a) }
    specify { expect(BatchEnumerator.new(1, 1000, reader).each_batch.to_a.size).to eq(1000) }
    specify { expect(BatchEnumerator.new(1, 1000, reader).each_batch.to_a[0].size).to eq(1) }
    specify { expect(BatchEnumerator.new(1, 1000, reader).each_batch.to_a[0]).to eq([1]) }
    specify { expect(BatchEnumerator.new(100, Float::INFINITY, reader).each_batch.to_a.size).to eq(100) }
    specify { expect(BatchEnumerator.new(100, 99, reader).each_batch.to_a.size).to eq(1) }
    specify { expect(BatchEnumerator.new(100, 99, reader).each_batch.to_a[0].size).to eq(99) }
    specify { expect(BatchEnumerator.new(100, 199, reader).each_batch.to_a.size).to eq(2) }
    specify { expect(BatchEnumerator.new(100, 199, reader).each_batch.to_a[0].size).to eq(100) }
    specify { expect(BatchEnumerator.new(100, 199, reader).each_batch.to_a[0]).to eq(collection[0..99]) }
    specify { expect(BatchEnumerator.new(100, 199, reader).each_batch.to_a[1].size).to eq(99) }
    specify { expect(BatchEnumerator.new(100, 199, reader).each_batch.to_a[1]).to eq(collection[100..198]) }
    specify do
      expect { |b| BatchEnumerator.new(1000, Float::INFINITY, reader).each_batch(&b) }.to yield_successive_args(
        collection[0...1000],
        collection[1000...2000],
        collection[2000...3000],
        collection[3000...4000],
        collection[4000...5000],
        collection[5000...6000],
        collection[6000...7000],
        collection[7000...8000],
        collection[8000...9000],
        collection[9000...10000]
      )
    end

    specify do
      expect(collection).to receive(:drop).once.and_call_original
      BatchEnumerator.new(100, 100, reader).each_batch.to_a
    end

    specify do
      expect(reader = double(:reader)).to receive(:call).with(kind_of(Integer), kind_of(Integer)).and_return([])
      BatchEnumerator.new(100, Float::INFINITY, reader).each_batch.to_a
    end
  end
end
