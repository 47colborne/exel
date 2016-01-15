Dir[File.expand_path('../../lib/**/*.rb', __FILE__)].each { |f| require f }

EXEL.logger = nil

module EXEL
  module Providers
    class DummyAsyncProvider
      def initialize(_context)
      end

      def do_async(_block)
      end
    end

    class DummyRemoteProvider
      def upload(_file)
      end

      def download(_uri)
      end

      def self.remote?(_uri)
      end
    end
  end
end

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
