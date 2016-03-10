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

  describe '.remote_provider' do
    context 'with no remote provider set in the configuration' do
      it 'defaults to NullRemoteProvider' do
        expect(EXEL.remote_provider).to eq(EXEL::Providers::LocalFileProvider)
      end
    end

    context 'with no remote provider set in the configuration' do
      before do
        EXEL.configure do |config|
          config.remote_provider = EXEL::Providers::DummyRemoteProvider
        end
      end

      it 'returns the configurated remote provider' do
        expect(EXEL.remote_provider).to eq(EXEL::Providers::DummyRemoteProvider)
      end
    end
  end

  after :each do
    EXEL.configure do |config|
      config.remote_provider = nil # reset providers to default
      config.async_provider = nil
    end
  end
end
