module EXEL
  describe DeferredContextValue do
    subject(:deferred_value) { DeferredContextValue.new }

    describe '.resolve' do
      subject(:deferred_value) { DeferredContextValue.new[:key] }

      context 'at the top level' do
        let(:context) { {key: 'value', deferred_value: deferred_value} }

        it 'returns the lookup value from the context' do
          expect(DeferredContextValue.resolve(context[:deferred_value], context)).to eq(context[:key])
        end
      end

      context 'in an array' do
        let(:context) { {key: 'value', array: [1, 2, deferred_value]} }

        it 'returns the lookup value from the context' do
          expect(DeferredContextValue.resolve(context[:array], context)).to eq([1, 2, context[:key]])
        end
      end

      context 'in a hash' do
        let(:context) { {key: 'value', hash: {hash_key: deferred_value}} }

        it 'returns the lookup value from the context' do
          expect(DeferredContextValue.resolve(context[:hash], context)).to eq(hash_key: context[:key])
        end
      end

      context 'in a hash nested in an array' do
        let(:context) { {key: 'value', nested: [{}, {hash_key: deferred_value}]} }

        it 'looks up a deferred context value in a hash nested in an array' do
          expect(DeferredContextValue.resolve(context[:nested], context)).to eq([{}, {hash_key: context[:key]}])
        end
      end

      context 'in an array nested in a hash' do
        let(:context) { {key: 'value', nested: {hash_key: [1, deferred_value]}} }

        it 'looks up a deferred context value in an array nested in a hash' do
          expect(DeferredContextValue.resolve(context[:nested], context)).to eq(hash_key: [1, context[:key]])
        end
      end
    end

    describe '#[]' do
      it 'stores the given key in the keys attribute' do
        deferred_value[:top_level_key]['sub_key']
        expect(deferred_value.keys).to eq([:top_level_key, 'sub_key'])
      end
    end

    describe '#get' do
      it 'looks up the value of the keys attribute in the passed-in context' do
        allow(deferred_value).to receive(:keys).and_return([:top_level_key, 'sub_key'])
        value = 'example_value'
        context = Context.new(top_level_key: {'sub_key' => value})
        expect(deferred_value.get(context)).to eq(value)
      end
    end
  end
end
