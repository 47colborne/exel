require_relative '../processor_helper'

module EXEL
  module Processors
    # Implements the +run+ instruction.
    class RunProcessor
      include EXEL::ProcessorHelper

      # Requires +context[:job]+ to contain the name of the job to be run.
      def initialize(context)
        @context = context
      end

      # Runs the specified job with the current context
      def process(_block = nil)
        log_process "running job #{@context[:job]}" do
          EXEL::Job.run(@context[:job], @context)
        end
      end
    end
  end
end
