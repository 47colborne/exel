module EXEL
  describe Context do
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
      before { allow(Value).to receive(:upload) }

      it 'writes the serialized context to a file and upload it' do
        expect(Value).to receive(:remotize).with(context[:key1]).and_return('remote_value1')
        expect(Value).to receive(:remotize).with(context[:key2]).and_return('remote_value2')

        expect(SecureRandom).to receive(:uuid).and_return('uuid')

        expect(Value).to receive(:remotize) do |file|
          expect(file.read).to eq(Marshal.dump(Context.new(key1: 'remote_value1', key2: 'remote_value2')))
          expect(file.path).to include('uuid')
          'file_uri'
        end

        expect(context.serialize).to eq('file_uri')
      end

      it 'does not mutate the current context' do
        allow(Value).to receive(:remotize).and_return('remote_value')
        original_table = context.dup
        context.serialize
        expect(context).to eq(original_table)
      end
    end

    describe '.deserialize' do
      it 'deserializes a given uri' do
        file = StringIO.new(Marshal.dump(context))
        expect(Value).to receive(:localize).with('uri').and_return(file)

        expect(Context.deserialize('uri')).to eq(context)

        expect(file).to be_closed
      end
    end

    describe '#[]' do
      subject(:context) { EXEL::Context.new(key: 'value') }

      it 'returns the value' do
        expect(context[:key]).to eq('value')
      end

      it 'localizes the returned value' do
        expect(Value).to receive(:localize).with('value').and_return('localized')
        expect(context[:key]).to eq('localized')
      end

      it 'stores the localized value' do
        allow(Value).to receive(:localize).with('value').and_return('localized')
        context[:key]
        allow(Value).to receive(:localize).with('localized').and_return('localized')
        context[:key]
      end

      context 'DeferredContextValue object' do
        context 'at the top level' do
          it 'returns the lookup value from the context' do
            deferred_context_value = DeferredContextValue.new[:key]
            context[:deferred_value] = deferred_context_value
            expect(context[:deferred_value]).to eq(context[:key])
          end
        end

        context 'in an array' do
          it 'returns the lookup value from the context' do
            deferred_context_value = DeferredContextValue.new[:key]
            context[:array] = [1, 2, deferred_context_value]
            expect(context[:array]).to eq([1, 2, context[:key]])
          end
        end

        context 'in a hash' do
          it 'returns the lookup value from the context' do
            deferred_context_value = DeferredContextValue.new[:key]
            context[:hash] = {hash_key: deferred_context_value}
            expect(context[:hash]).to eq(hash_key: context[:key])
          end
        end

        context 'in nested arrays and hashes' do
          it 'looks up a deferred context value in a hash nested in an array' do
            deferred_context_value = DeferredContextValue.new[:key]
            context[:nested] = [{}, {hash_key: deferred_context_value}]
            expect(context[:nested]).to eq([{}, {hash_key: context[:key]}])
          end

          it 'looks up a deferred context value in an array nested in a hash' do
            deferred_context_value = DeferredContextValue.new[:key]
            context[:nested] = {hash_key: [1, deferred_context_value]}
            expect(context[:nested]).to eq(hash_key: [1, context[:key]])
          end
        end
      end
    end
  end
end
