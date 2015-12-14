module EXEL
  module Resource
    def self.remotize(value)
      file?(value) ? upload(value) : value
    end

    def self.localize(value)
      remote?(value) ? download(value) : value
    end

    class << self
      private

      def file?(value)
        value.is_a?(File) || value.is_a?(Tempfile)
      end

      def upload(file)
        Handlers::S3Handler.new.upload(file)
      end

      def remote?(value)
        value =~ %r{^s3://}
      end

      def download(uri)
        Handlers::S3Handler.new.download(uri)
      end
    end
  end
end
