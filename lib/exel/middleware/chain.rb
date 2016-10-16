# frozen_string_literal: true
module EXEL
  # Middleware is code configured to run around each processor execution. Custom middleware can be added as follows:
  #
  #   EXEL.configure do |config|
  #     config.middleware.add(MyMiddleware)
  #     config.middleware.add(AnotherMiddleware, 'constructor arg')
  #   end
  #
  # Middleware can be any class that implements a +call+ method that includes a call to +yield+:
  #
  #   class MyMiddleware
  #     def call(processor, context, args)
  #       puts 'before process'
  #       yield
  #       puts 'after process'
  #     end
  #   end
  #
  # The +call+ method will be passed the class of the processor that will be executed, the current context, and any args
  # that were passed to the processor in the job definition.
  module Middleware
    # Chain of middleware to be invoked in sequence around each processor execution.
    class Chain
      attr_reader :entries

      Entry = Struct.new(:klass, :args)

      def initialize
        @entries = []
      end

      # Adds a middleware class to the chain. If it is already in the chain it will be removed and added to the end.
      # Any additional arguments will be passed to +new+ when the middleware is created.
      def add(klass, *args)
        remove(klass)
        @entries << Entry.new(klass, args)
      end

      # Removes a middleware class from the chain.
      def remove(klass)
        @entries.delete_if { |entry| entry.klass == klass }
      end

      # Returns true if the given class is in the chain.
      def include?(klass)
        @entries.any? { |entry| entry.klass == klass }
      end

      # Calls each middleware in the chain.
      def invoke(*args)
        chain = @entries.map { |entry| entry.klass.new(*entry.args) }

        traverse_chain = lambda do
          if chain.empty?
            yield
          else
            chain.shift.call(*args, &traverse_chain)
          end
        end

        traverse_chain.call
      end
    end
  end
end
