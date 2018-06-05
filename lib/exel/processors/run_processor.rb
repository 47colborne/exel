# frozen_string_literal: true

module EXEL
  module Processors
    # Implements the +run+ instruction.
    class RunProcessor
      # Requires +context[:job]+ to contain the name of the job to be run.
      def initialize(context)
        @context = context
      end

      # Runs the specified job with the current context
      def process(_block = nil)
        EXEL::Job.run(@context[:job], @context)
      end
    end
  end
end
