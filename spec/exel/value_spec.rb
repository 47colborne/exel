# frozen_string_literal: true

describe EXEL::Value do
  let(:uri) { 's3://test_file.csv' }

  before { allow(EXEL).to receive(:remote_provider).and_return(EXEL::Providers::DummyRemoteProvider) }

  describe '.remotize' do
    context 'when the value is not a file' do
      it 'returns the value' do
        expect(EXEL::Value.remotize('test')).to eq('test')
      end
    end

    [File, Tempfile].each do |file_class|
      context "when the value is an instance of #{file_class}" do
        let(:file) { instance_double(file_class) }

        before { allow(file).to receive(:is_a?) { |klass| klass == file_class } }

        it 'uploads the file using the remote provider' do
          expect_any_instance_of(EXEL::Providers::DummyRemoteProvider).to receive(:upload).with(file)
          EXEL::Value.remotize(file)
        end

        it 'returns the URI of the uploaded file' do
          allow_any_instance_of(EXEL::Providers::DummyRemoteProvider).to receive(:upload).with(file).and_return(uri)
          expect(EXEL::Value.remotize(file)).to eq(uri)
        end
      end
    end
  end

  describe '.localize' do
    context 'with a local value' do
      it 'returns the value' do
        expect(EXEL::Value.localize('test')).to eq('test')
      end
    end

    context 'with a remote file' do
      it 'returns the downloaded file' do
        expect(EXEL::Providers::DummyRemoteProvider).to receive(:remote?).with(uri).and_return(true)
        file = double(:file)
        expect_any_instance_of(EXEL::Providers::DummyRemoteProvider).to receive(:download).with(uri).and_return(file)

        expect(EXEL::Value.localize(uri)).to eq(file)
      end
    end
  end
end
