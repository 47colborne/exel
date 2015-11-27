module EXEL
  module Handlers
    describe S3Handler do
      subject(:handler) { S3Handler.new }

      describe '#get_object' do
        before do
          EXEL.configure { |config| config.s3_bucket = 'bucket' }
        end

        it 'should have the correct bucket and file names' do
          file_name = 'abc.txt'
          s3_obj = handler.get_object(file_name)
          expect(s3_obj.bucket_name).to eq('bucket')
          expect(s3_obj.key).to eq(file_name)
        end
      end

      describe '#upload' do
        let(:file) { double(path: '/path/to/abc.txt', close: nil) }

        it 'should upload a file to s3' do
          expect_any_instance_of(Aws::S3::Object).to receive(:upload_file).with(file)

          handler.upload(file)
        end

        it 'should return the file URI of the uploaded file' do
          allow_any_instance_of(Aws::S3::Object).to receive(:upload_file).with(file)
          expect(handler.upload(file)).to eq('s3://abc.txt')
        end
      end

      describe '#download' do
        it 'should download the file from s3' do
          file = double(:file)
          s3_object = double(:s3_object)

          expect(handler).to receive(:get_object).with('abc.txt').and_return(s3_object)
          expect(Tempfile).to receive(:new).with('abc.txt', encoding: Encoding::ASCII_8BIT).and_return(file)
          expect(s3_object).to receive(:get).with(hash_including(response_target: file)).and_return(file)
          expect(file).to receive(:set_encoding).with(Encoding::UTF_8)

          expect(handler.download('s3://abc.txt')).to eq(file)
        end
      end
    end
  end
end
