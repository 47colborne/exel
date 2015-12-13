module EXEL
  describe Resource do
    let(:s3_uri) { 's3://test_file.csv' }

    describe '.remotize' do
      context 'when passed in value is not a file' do
        it 'should return the value' do
          expect(Resource.remotize('test string')).to eq('test string')
        end
      end

      context 'when the passed in value is a file' do
        [File, Tempfile].each do |file_class|
          context "with a #{file_class}" do
            let(:file) { instance_double(file_class) }

            before { allow(file).to receive(:is_a?) { |klass| klass == file_class } }

            it 'should upload the file to S3' do
              expect_any_instance_of(Handlers::S3Handler).to receive(:upload).with(file)
              Resource.remotize(file)
            end

            it 'should return a remote file URI' do
              allow_any_instance_of(Handlers::S3Handler).to receive(:upload).with(file).and_return(s3_uri)
              expect(Resource.remotize(file)).to eq(s3_uri)
            end
          end
        end
      end
    end

    describe '.localize' do
      context 'with a localized value' do
        it 'should return the value' do
          expect(Resource.localize('test string')).to eq('test string')
        end
      end

      context 'with a remote file' do
        it 'should return the downloaded file' do
          file = double(:file)
          expect_any_instance_of(Handlers::S3Handler).to receive(:download).with(s3_uri).and_return(file)

          expect(Resource.localize(s3_uri)).to eq(file)
        end
      end
    end
  end
end
