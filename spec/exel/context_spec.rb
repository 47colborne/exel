module EXEL
  describe Context do
    subject(:context) { EXEL::Context.new(test1: 'foo', test2: 2) }

    describe '#initialize' do
      it 'should be able to initialize with a hash' do
        expect(context.table[:test1]).to eq('foo')
        expect(context.table[:test2]).to eq(2)
      end
    end

    describe '#serialize' do
      let(:handler) { instance_double(Handlers::S3Handler, upload: nil) }

      before do
        allow(Handlers::S3Handler).to receive(:new).and_return(handler) #TODO don't stub new
      end

      it 'should write the serialized context to a file and upload it' do
        expect(Resource).to receive(:remotize).with(context[:test1]).and_return('remote_value1')
        expect(Resource).to receive(:remotize).with(context[:test2]).and_return('remote_value2')

        expect(SecureRandom).to receive(:uuid).and_return('uuid')

        expect(handler).to receive(:upload) do |file|
          expect(file.read).to eq(Marshal.dump(Context.new(test1: 'remote_value1', test2: 'remote_value2')))
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
        uri = 'test_uri'
        file = StringIO.new(Marshal.dump(context))
        expect_any_instance_of(Handlers::S3Handler).to receive(:download).with(uri).and_return(file)

        expect(Context.deserialize(uri)).to eq(context)

        expect(file).to be_closed
      end
    end

    describe '#[]' do
      subject(:context) { EXEL::Context.new(key: Resource.remotize('value')) }

      it 'should return localized values' do
        expect(context[:key]).to eq('value')
      end

      it 'should store the localized value' do
        context[:key]
        expect(context.table[:key]).to eq('value')
      end

      context 'DeferredContextValue object' do
        context 'at the top level' do
          it 'should return the lookup value from the context' do
            deferred_context_value = DeferredContextValue.new[:key]
            context[:deferred_value] = deferred_context_value
            expect(context[:deferred_value]).to eq(context[:key])
          end
        end
        context 'in array' do
          it 'should return the lookup value from the context' do
            deferred_context_value = DeferredContextValue.new[:key]
            context[:array] = [1, 2, deferred_context_value]
            expect(context[:array]).to eq([1, 2, context[:key]])
          end
        end

        context 'in hash' do
          it 'should return the lookup value from the context' do
            deferred_context_value = DeferredContextValue.new[:key]
            context[:hash] = {hash_key: deferred_context_value}
            expect(context[:hash]).to eq({hash_key: context[:key]})
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
            expect(context[:nested]).to eq({hash_key: [1, context[:key]]})
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

  end
end
