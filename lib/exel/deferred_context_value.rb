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
      keys.reduce(context) { |acc, key| acc[key] }
    end
  end
end