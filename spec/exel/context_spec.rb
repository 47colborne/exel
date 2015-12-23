module EXEL
  describe Context do
    subject(:context) { EXEL::Context.new(key1: '1', key2: 2) }

    describe '#initialize' do
      it 'should be able to initialize with a hash' do
        expect(context.table[:key1]).to eq('1')
        expect(context.table[:key2]).to eq(2)
      end
    end

    describe '#deep_dup' do
      it 'returns a deep copy of itself' do
        context[:a] = {nested: []}

        dup = context.deep_dup
        expect(context).to eq(dup)
        expect(context).to_not be_equal(dup)

        dup[:a][:nested] << 1
        expect(context[:a][:nested]).to be_empty
      end
    end

    describe '#serialize' do
      before { allow(Value).to receive(:upload) }

      it 'should write the serialized context to a file and upload it' do
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

      it 'should not mutate the current context' do
        original_table = context.table.dup
        context.serialize
        expect(context.table).to eq(original_table)
      end
    end

    describe '.deserialize' do
      it 'should deserialize a given uri' do
        file = StringIO.new(Marshal.dump(context))
        expect(Value).to receive(:localize).with('uri').and_return(file)

        expect(Context.deserialize('uri')).to eq(context)

        expect(file).to be_closed
      end
    end

    describe '#[]' do
      subject(:context) { EXEL::Context.new(key: 'value') }

      it 'should return the value' do
        expect(context[:key]).to eq('value')
      end

      it 'should localize the returned value' do
        expect(Value).to receive(:localize).with('value').and_return('localized')
        expect(context[:key]).to eq('localized')
      end

      it 'should store the localized value' do
        allow(Value).to receive(:localize).with('value').and_return('localized')
        context[:key]
        expect(context.table[:key]).to eq('localized')
      end

      context 'DeferredContextValue object' do
        context 'at the top level' do
          it 'should return the lookup value from the context' do
            deferred_context_value = DeferredContextValue.new[:key]
            context[:deferred_value] = deferred_context_value
            expect(context[:deferred_value]).to eq(context[:key])
          end
        end

        context 'in an array' do
          it 'should return the lookup value from the context' do
            deferred_context_value = DeferredContextValue.new[:key]
            context[:array] = [1, 2, deferred_context_value]
            expect(context[:array]).to eq([1, 2, context[:key]])
          end
        end

        context 'in a hash' do
          it 'should return the lookup value from the context' do
            deferred_context_value = DeferredContextValue.new[:key]
            context[:hash] = {hash_key: deferred_context_value}
            expect(context[:hash]).to eq(hash_key: context[:key])
          end
        end

        context 'in nested arrays and hashes' do
          it 'should lookup a deferred context value in a hash nested in an array' do
            deferred_context_value = DeferredContextValue.new[:key]
            context[:nested] = [{}, {hash_key: deferred_context_value}]
            expect(context[:nested]).to eq([{}, {hash_key: context[:key]}])
          end

          it 'should lookup a deferred context value in an array nested in a hash' do
            deferred_context_value = DeferredContextValue.new[:key]
            context[:nested] = {hash_key: [1, deferred_context_value]}
            expect(context[:nested]).to eq(hash_key: [1, context[:key]])
          end
        end
      end
    end

    describe '#[]=' do
      it 'should add the key/value pair to table' do
        context[:new_key] = 'new_value'
        expect(context.table[:new_key]).to eq('new_value')
      end
    end

    describe '#delete' do
      it 'should delete the key/value pair from the table' do
        context[:key] = 'value'
        context[:key2] = 'value2'
        context.delete(:key)
        expect(context.table.keys).to_not include(:key)
        expect(context.table.keys).to include(:key2)
      end
    end

    describe '#merge!' do
      it 'should merge given keys and values into the context' do
        context.table[:overwrite] = 'overwrite'
        context.table[:existing] = 'existing'

        context.merge!(overwrite: 'changed', new: 'new')

        expect(context.table[:overwrite]).to eq('changed')
        expect(context.table[:existing]).to eq('existing')
        expect(context.table[:new]).to eq('new')
      end

      it 'should return itself' do
        expect(context.merge!(key: 'value')).to eq(context)
      end
    end

    describe '#==' do
      it { is_expected.to_not eq(nil) }

      it { is_expected.to eq(context) }

      it { is_expected.to_not eq(42) }

      it { is_expected.to_not eq(Context.new(other_key: 'value')) }

      it { is_expected.to eq(context.dup) }
    end

    describe 'include?' do
      subject(:context) { EXEL::Context.new(key1: 1, key2: 2, key3: 3) }

      context 'context contains all key value pairs' do
        it 'should return true' do
          expect(context).to include(key1: 1, key2: 2)
        end
      end

      context 'context does not contain all key value pairs' do
        it 'should return true' do
          expect(context).not_to include(foo: 'bar', key2: 2)
        end
      end
    end
  end
end
