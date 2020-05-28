# frozen_string_literal: true

describe EXEL::Providers::LocalFileProvider do
  let(:file) { File.open(File.expand_path('../../../fixtures/sample.csv', __FILE__)) }

  it 'can upload/download a file' do
    remote_value = subject.upload(file)
    expect(remote_value.uri.path).to eq(file.path)

    restored_file = subject.download(remote_value)
    expect(restored_file.path).to eq(file.path)
  end

  it 'doesn`t accept URIs for schemes other than file://' do
    expect { subject.download(RemoteValue.new(URI('s3://bucket/file'))) }.to raise_error "Unsupported URI scheme 's3'"
  end

  describe '.remote?' do
    it 'returns true for remote values' do
      expect(EXEL::Providers::LocalFileProvider.remote?(RemoteValue.new(URI('file:///path/to/file')))).to be_truthy
    end

    it 'returns false for file:// URIs' do
      expect(EXEL::Providers::LocalFileProvider.remote?('file:///path/to/file')).to be_falsey
      expect(EXEL::Providers::LocalFileProvider.remote?(URI('file:///path/to/file'))).to be_falsey
    end

    it 'returns false for anything else' do
      expect(EXEL::Providers::LocalFileProvider.remote?('s3://file')).to be_falsey
      expect(EXEL::Providers::LocalFileProvider.remote?(1)).to be_falsey
      expect(EXEL::Providers::LocalFileProvider.remote?(nil)).to be_falsey
    end
  end
end
