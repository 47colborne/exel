# frozen_string_literal: true
module EXEL
  # When +context+ is referenced in a job definition, an instance of +DeferredContextValue+ will be put in its place.
  # At runtime, the first time a +DeferredContextValue+ is read via {EXEL::Context#[]}, it will be replaced by the value
  # it was referring to.
  #
  # Example:
  #   process with: MyProcessor, foo: context[:bar]
  class DeferredContextValue
    attr_reader :keys

    class << self
      # If +value+ is an instance of +DeferredContextValue+, it will be resolved to its actual value in the context. If
      # it is an +Array+ or +Hash+ all +DeferredContextValue+ instances within it will be resolved. If it is anything
      # else, it will just be returned.
      #
      # @return value, with all +DeferredContextValue+ instances resolved
      def resolve(value, context)
        if deferred?(value)
          value = value.get(context)
        elsif value.is_a?(Array)
          value.map! { |v| resolve(v, context) }
        elsif value.is_a?(Hash)
          value.each { |k, v| value[k] = resolve(v, context) }
        end

        value
      end

      private

      def deferred?(value)
        value.is_a?(DeferredContextValue)
      end
    end

    def initialize
      @keys = []
    end

    # Records the keys that will be used to lookup the value from the context at runtime. Supports nested hashes
    # such as:
    #   context[:hash1][:hash2][:key]
    def [](key)
      keys << key
      self
    end

    # Given a context, returns the value that this instance was acting as a placeholder for.
    def get(context)
      keys.reduce(context) { |acc, elem| acc[elem] }
    end
  end
end
