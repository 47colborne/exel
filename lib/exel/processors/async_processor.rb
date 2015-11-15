require 'sidekiq'
require_relative '../processor_helper'

module EXEL
  module Processors
    class AsyncProcessor
      include EXEL::ProcessorHelper

      def initialize(context)
        @context = context

        log_prefix_with '[AsyncProcessor]'
      end

      def process(callback)
        log_process do
          @context[:_block] = callback

          push_args = {'class' => ExecutionWorker, 'args' => [@context.serialize]}
          push_args['queue'] = @context[:queue] if @context[:queue]
          push_args['retry'] = @context[:retry] if @context[:retry]

          Sidekiq::Client.push(push_args)
          log_info 'call to async completed'
        end
      end
    end
  end
end
