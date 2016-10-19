# frozen_string_literal: true

module EXEL
  module Processors
    # Implements the +async+ instruction by using the configured async provider to run a block asynchronously.
    class AsyncProcessor
      attr_reader :provider

      def initialize(context)
        @context = context
        @provider = EXEL.async_provider.new(context)
      end

      def process(block)
        @provider.do_async(block)
      end
    end
  end
end
