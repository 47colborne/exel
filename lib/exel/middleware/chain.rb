# frozen_string_literal: true
module EXEL
  module Middleware
    # Chain of middleware to be invoked around each processor execution
    class Chain
      attr_reader :entries

      Entry = Struct.new(:klass, :args)

      def initialize
        @entries = []
      end

      def add(klass, *args)
        remove(klass)
        @entries << Entry.new(klass, args)
      end

      def remove(klass)
        @entries.delete_if { |entry| entry.klass == klass }
      end

      def include?(klass)
        @entries.any? { |entry| entry.klass == klass }
      end

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
