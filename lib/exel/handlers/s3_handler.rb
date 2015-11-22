require 'aws-sdk-resources'
require 'tempfile'

module EXEL
  module Handlers
    class S3Handler
      def upload(file)
        filename = get_filename(file)
        obj = get_object(filename)
        obj.upload_file(file)
        file.close

        "s3://#{filename}"
      end

      def download(uri)
        filename = uri.partition('://').last
        obj = get_object(filename)
        file = Tempfile.new(filename, encoding: Encoding::ASCII_8BIT)
        obj.get(response_target: file)
        file.set_encoding(Encoding::UTF_8)
        file
      end

      def get_object(filename)
        s3 = Aws::S3::Resource.new(
            credentials: Aws::Credentials.new(
                EXEL.configuration[:aws][:access_key_id],
                EXEL.configuration[:aws][:secret_access_key]
            ),
            region: 'us-east-1'
        )
        s3.bucket(EXEL.configuration[:s3_bucket]).object(filename)
      end

      private

      def get_filename(file)
        file.path.split('/').last
      end
    end
  end
end
