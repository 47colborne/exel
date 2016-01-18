require_relative '../processor_helper'

module EXEL
  module Processors
    # Implements the +async+ instruction by using the configured async provider to run a block asynchronously.
    class AsyncProcessor
      include EXEL::ProcessorHelper
      attr_reader :provider

      def initialize(context)
        @context = context
        @provider = EXEL.async_provider.new(context)

        log_prefix_with '[AsyncProcessor]'
      end

      def process(block)
        log_process do
          @provider.do_async(block)
          log_info 'call to async completed'
        end
      end
    end
  end
end
