require_relative '../processor_helper'

module EXEL
  module Processors
    class AsyncProcessor
      include EXEL::ProcessorHelper
      attr_reader :handler

      def initialize(context)
        @context = context
        @handler = EXEL::Handlers::SidekiqHandler.new(context)

        log_prefix_with '[AsyncProcessor]'
      end

      def process(block)
        log_process do
          @handler.do_async(block)
          log_info 'call to async completed'
        end
      end
    end
  end
end
