# frozen_string_literal: true

describe EXEL::Context do
  subject(:context) { EXEL::Context.new(key1: '1', key2: 2) }

  it { is_expected.to be_a(Hash) }

  describe '#initialize' do
    it 'initializes with a hash' do
      expect(context[:key1]).to eq('1')
      expect(context[:key2]).to eq(2)
      expect(context[:key3]).to be_nil
    end
  end

  describe '#deep_dup' do
    it 'returns a deep copy of itself' do
      context[:a] = {nested: []}

      dup = context.deep_dup
      expect(context).to eq(dup)
      expect(context).not_to be_equal(dup)

      dup[:a][:nested] << 1
      expect(context[:a][:nested]).to be_empty
    end
  end

  describe '#serialize' do
    before { allow(EXEL::Value).to receive(:upload) }

    it 'writes the serialized context to a file and upload it' do
      expect(EXEL::Value).to receive(:remotize).with(context[:key1]).and_return('remote_value1')
      expect(EXEL::Value).to receive(:remotize).with(context[:key2]).and_return('remote_value2')

      expect(SecureRandom).to receive(:uuid).and_return('uuid')

      expect(EXEL::Value).to receive(:remotize) do |file|
        expect(file.read).to eq(Marshal.dump(EXEL::Context.new(key1: 'remote_value1', key2: 'remote_value2')))
        expect(file.path).to include('uuid')
        'file_uri'
      end

      expect(context.serialize).to eq('file_uri')
    end

    it 'does not mutate the current context' do
      allow(EXEL::Value).to receive(:remotize).and_return('remote_value')
      original_table = context.dup
      context.serialize
      expect(context).to eq(original_table)
    end
  end

  describe '.deserialize' do
    it 'deserializes a given uri' do
      file = StringIO.new(Marshal.dump(context))
      expect(EXEL::Value).to receive(:localize).with('uri').and_return(file)

      expect(EXEL::Context.deserialize('uri')).to eq(context)

      expect(file).to be_closed
    end
  end

  shared_examples 'a reader method' do
    subject(:context) { EXEL::Context.new(key: 'value') }

    it 'returns the value' do
      expect(context.send(method, :key)).to eq('value')
    end

    it 'localizes the returned value' do
      expect(EXEL::Value).to receive(:localize).with('value').and_return('localized')
      expect(context.send(method, :key)).to eq('localized')
    end

    it 'stores the localized value' do
      allow(EXEL::Value).to receive(:localize).with('value').and_return('localized')
      context.send(method, :key)
      allow(EXEL::Value).to receive(:localize).with('localized').and_return('localized')
      context.send(method, :key)
    end

    it 'looks up deferred values' do
      # eq(context) as an argument matcher is necessary to prevent RSpec from calling fetch on the context, leading to
      # a stack overflow
      expect(EXEL::DeferredContextValue).to receive(:resolve).with('value', eq(context)).and_return('resolved')
      expect(context.send(method, :key)).to eq('resolved')
    end
  end

  describe '#[]' do
    it_behaves_like 'a reader method' do
      let(:method) { :[] }
    end
  end

  describe '#fetch' do
    it 'raises an exception if the key is not found' do
      expect { context.fetch(:unknown) }.to raise_error(KeyError)
    end

    it_behaves_like 'a reader method' do
      let(:method) { :fetch }
    end
  end
end
