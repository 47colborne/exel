module EXEL
  module Providers
    class LocalFileProvider
      def upload(file)
        "file://#{file.path}"
      end

      def download(uri)
        fail 'URI must begin with "file://"' unless uri.start_with? 'file://'
        File.open(uri.split('file://').last)
      end

      def self.remote?(uri)
        uri =~ %r{file://}
      end
    end
  end
end
