module EXEL
  class Resource
    def self.remotize(value)
      file?(value) ? upload(value) : value
    end

    def self.localize(value)
      serialized?(value) ? deserialize_file(value) : value
    end

    class << self
      private

      def file?(value)
        value.is_a?(File) || value.is_a?(Tempfile)
      end

      def serialized?(value)
        value =~ %r{^s3://}
      end

      def deserialize_file(uri)
        download(uri)
      end

      def download(uri)
        Handlers::S3Handler.new.download(uri)
      end

      def upload(file)
        Handlers::S3Handler.new.upload(file)
      end
    end
  end
end
