require 'sidekiq'

module EXEL
  module Handlers
    class SidekiqHandler
      def initialize(context)
        @context = context
      end

      def do_async(block)
        @context[:_block] = block

        push_args = {'class' => ExecutionWorker, 'args' => [@context.serialize]}
        push_args['queue'] = @context[:queue] if @context[:queue]
        push_args['retry'] = @context[:retry] if @context[:retry]

        Sidekiq::Client.push(push_args)
      end
    end
  end
end
