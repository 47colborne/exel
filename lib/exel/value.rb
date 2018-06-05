# frozen_string_literal: true

module EXEL
  # Contains methods to handle remote and local values. Used for {Context} serialization
  module Value
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
        EXEL.remote_provider.new.upload(file)
      end

      def remote?(value)
        EXEL.remote_provider.remote?(value)
      end

      def download(uri)
        EXEL.remote_provider.new.download(uri)
      end
    end
  end
end
