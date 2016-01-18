module EXEL
  # When +context+ is referenced in a job definition, an instance of +DeferredContextValue+ will be put in its place.
  # At runtime, the first time a +DeferredContextValue+ is read via {EXEL::Context#[]}, it will be replaced by the value
  # it was referring to.
  #
  # Example:
  #   process with: MyProcessor, foo: context[:bar]
  class DeferredContextValue
    attr_reader :keys

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
      keys.reduce(context) { |a, e| a[e] }
    end
  end
end
