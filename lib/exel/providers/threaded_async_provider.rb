module EXEL
  module Providers
    # The default remote provider. Provides async execution by running the given EXEL block in a new Thread
    class ThreadedAsyncProvider
      def initialize(context)
        @context = context
      end

      def do_async(block)
        Thread.new { block.start(@context.deep_dup) }
      end
    end
  end
end
