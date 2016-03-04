module EXEL
  module Providers
    # The default remote provider. Doesn't actually upload and download files to and from remote storage, but rather
    # just works with local files.
    class LocalFileProvider
      def upload(file)
        "file://#{file.path}"
      end

      def download(uri)
        raise 'URI must begin with "file://"' unless uri.start_with? 'file://'
        File.open(uri.split('file://').last)
      end

      def self.remote?(uri)
        uri =~ %r{file://}
      end
    end
  end
end
