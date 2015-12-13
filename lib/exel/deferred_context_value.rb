module EXEL
  class DeferredContextValue
    attr_reader :keys

    def initialize
      @keys = []
    end

    def [](key)
      keys << key
      self
    end

    def get(context)
      keys.reduce(context) { |a, e| a[e] }
    end
  end
end
