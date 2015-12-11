describe EXEL do
  describe '.async_provider' do
    context 'with no async provider set in the configuration' do
      it 'defaults to ThreadedAsyncProvider' do
        expect(EXEL.async_provider).to eq(EXEL::Providers::ThreadedAsyncProvider)
      end
    end

    context 'with an async provider set in the configuration' do
      before do
        EXEL.configure do |config|
          config.async_provider = EXEL::Providers::DummyAsyncProvider
        end
      end

      it 'returns the configured async provider' do
        expect(EXEL.async_provider).to eq(EXEL::Providers::DummyAsyncProvider)
      end
    end
  end
end
