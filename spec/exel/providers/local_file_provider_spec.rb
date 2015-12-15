module EXEL
  module Providers
    describe LocalFileProvider do
      let(:file) { instance_double(File, path: '/path/to/file') }

      describe '#upload' do
        it 'returns a file:// URI for the file' do
          expect(subject.upload(file)).to eq('file:///path/to/file')
        end
      end

      describe '#download' do
        it 'returns the file indicated by the URI' do
          expect(File).to receive(:open).with('/path/to/file').and_return(file)
          expect(subject.download('file:///path/to/file')).to eq(file)
        end

        it 'doesn`t accept URIs for schemes other than file://' do
          expect { subject.download('s3://') }.to raise_error 'URI must begin with "file://"'
        end
      end

      describe '.remote?' do
        it 'returns true for file:// URIs' do
          expect(LocalFileProvider.remote?('file:///path/to/file')).to be_truthy
        end

        it 'returns false for anything else' do
          expect(LocalFileProvider.remote?('s3://file')).to be_falsey
          expect(LocalFileProvider.remote?(1)).to be_falsey
          expect(LocalFileProvider.remote?(nil)).to be_falsey
        end
      end
    end
  end
end
