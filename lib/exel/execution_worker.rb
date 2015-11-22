require 'sidekiq'

module EXEL
  class ExecutionWorker
    include Sidekiq::Worker

    def perform(context_uri)
      context = Context.deserialize(context_uri)
      block = context[:_block]
      block.start(context)
    end
  end
end