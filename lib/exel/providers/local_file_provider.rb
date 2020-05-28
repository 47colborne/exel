# frozen_string_literal: true

module EXEL
  module Providers
    # The default remote provider. Doesn't actually upload and download files to and from remote storage, but rather
    # just works with local files.
    class LocalFileProvider
      def upload(file)
        RemoteValue.new(URI("file://#{File.absolute_path(file)}"))
      end

      def download(remote_value)
        scheme = remote_value.uri.scheme
        raise "Unsupported URI scheme '#{scheme}'" unless scheme == 'file'
        File.open(remote_value.uri.path)
      end

      def self.remote?(value)
        value.is_a?(RemoteValue)
      end
    end
  end
end
