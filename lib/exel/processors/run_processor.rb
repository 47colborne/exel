require_relative '../processor_helper'

module EXEL
  module Processors
    class RunProcessor
      include EXEL::ProcessorHelper

      def initialize(context)
        @context = context
      end

      def process(_block = nil)
        log_process "running job #{@context[:job]}" do
          EXEL::Job.run(@context[:job], @context)
        end
      end
    end
  end
end
