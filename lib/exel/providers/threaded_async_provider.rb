module EXEL
  module Providers
    class ThreadedAsyncProvider
      def initialize(context)
        @context = context
      end

      def do_async(block)
        Thread.new { block.start(@context) }
      end
    end
  end
end
