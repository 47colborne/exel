module EXEL
  class Resource
    def self.remotize(value)
      file?(value) ? upload(value) : value
    end

    def self.localize(value)
      serialized?(value) ? deserialize_file(value) : value
    end

    private

    def self.file?(value)
      value.kind_of?(File) || value.kind_of?(Tempfile)
    end

    def self.serialized?(value)
      value =~ /^s3:\/\//
    end

    def self.deserialize_file(uri)
      download(uri)
    end

    def self.download(uri)
      Handlers::S3Handler.new.download(uri)
    end

    def self.upload(file)
      Handlers::S3Handler.new.upload(file)
    end
  end
end
