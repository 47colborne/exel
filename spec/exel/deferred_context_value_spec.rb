module EXEL
  describe DeferredContextValue do
    subject(:deferred_context_value) { DeferredContextValue.new }

    describe '#[]' do
      it 'stores the given key in the keys attribute' do
        deferred_context_value[:top_level_key]['sub_key']
        expect(deferred_context_value.keys).to eq([:top_level_key, 'sub_key'])
      end
    end

    describe '#get' do
      it 'looks up the value of the keys attribute in the passed-in context' do
        allow(deferred_context_value).to receive(:keys).and_return([:top_level_key, 'sub_key'])
        value = 'example_value'
        context = Context.new(top_level_key: {'sub_key' => value})
        expect(deferred_context_value.get(context)).to eq(value)
      end
    end
  end
end
