# frozen_string_literal: true
# require 'codeclimate-test-reporter'
# CodeClimate::TestReporter.start

require 'pry'

Dir[File.expand_path('../../lib/**/*.rb', __FILE__)].each { |f| require f }

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path('spec/support/**/*.rb')].each { |f| require f }

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

  config.order = 'random'
end
