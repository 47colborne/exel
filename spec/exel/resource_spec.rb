module EXEL
  describe Resource do
    let(:s3_uri) { 's3://test_file.csv' }

    describe '.remotize' do
      context 'when the value is not a file' do
        it 'returns the value' do
          expect(Resource.remotize('test string')).to eq('test string')
        end
      end

      [File, Tempfile].each do |file_class|
        context "when the value is an instance of #{file_class}" do
          let(:file) { instance_double(file_class) }

          before { allow(file).to receive(:is_a?) { |klass| klass == file_class } }

          it 'uploads the file to S3' do
            expect_any_instance_of(Handlers::S3Handler).to receive(:upload).with(file)
            Resource.remotize(file)
          end

          it 'returns the URI of the uploaded file' do
            allow_any_instance_of(Handlers::S3Handler).to receive(:upload).with(file).and_return(s3_uri)
            expect(Resource.remotize(file)).to eq(s3_uri)
          end
        end
      end
    end

    describe '.localize' do
      context 'with a local value' do
        it 'returns the value' do
          expect(Resource.localize('test')).to eq('test')
        end
      end

      context 'with a remote file' do
        it 'returns the downloaded file' do
          file = double(:file)
          expect_any_instance_of(Handlers::S3Handler).to receive(:download).with(s3_uri).and_return(file)

          expect(Resource.localize(s3_uri)).to eq(file)
        end
      end
    end
  end
end
