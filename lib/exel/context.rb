require 'tempfile'

module EXEL
  # The +Context+ is the shared memory of a running job. It acts as the source of input to processors and the place for
  # them to store their outputs. It can be serialized and deserialized to support remote execution.
  class Context
    # Internal hash of keys/values in the context. Use {#[]} and {#[]=} to get and set values instead of this.
    attr_reader :table

    # Accepts an optional hash of keys and values to initialize the context with.
    def initialize(initial_context = {})
      @table = initial_context
    end

    # Returns a deep copy of this context. The copy and the original will have no shared object references.
    #
    # @return [Context]
    def deep_dup
      Context.deserialize(serialize)
    end

    # Serializes this instance to a local file and uses the remote provider to upload it. Returns a URI indicating where
    # the serialized context can be downloaded.
    #
    # @return [String] A URI such as +s3://bucket/file+, +file:///path/to/file+, etc.
    def serialize
      EXEL::Value.remotize(serialized_context)
    end

    # Given a string representing the URI to a serialized context, downloads and returns the deserialized context
    #
    # @return [Context]
    def self.deserialize(uri)
      file = EXEL::Value.localize(uri)
      context = Marshal.load(file.read)
      file.close
      context
    end

    # Returns the value referenced by the given key
    def [](key)
      value = EXEL::Value.localize(@table[key])
      value = get_deferred(value)
      @table[key] = value
      value
    end

    # Stores the given key/value pair
    def []=(key, value)
      @table[key] = value
    end

    # Adds the given key/value pairs to the context, overriding any keys that are already present.
    #
    # @return [Context]
    def merge!(hash)
      @table.merge!(hash)
      self
    end

    # Removes the value referenced by +key+ from the context
    def delete(key)
      @table.delete(key)
    end

    # Two Contexts are equal if they contain the same key/value pairs
    def ==(other)
      other.is_a?(EXEL::Context) && table == other.table
    end

    # Returns true if this instance contains all of the given key/value pairs
    def include?(hash)
      @table.merge(hash) == @table
    end

    private

    def serialized_context
      file = Tempfile.new(SecureRandom.uuid, encoding: 'ascii-8bit')
      file.write(Marshal.dump(Context.new(remotized_table)))
      file.rewind
      file
    end

    def remotized_table
      @table.each_with_object({}) { |(key, value), acc| acc[key] = EXEL::Value.remotize(value) }
    end

    def get_deferred(value)
      if deferred?(value)
        value = value.get(self)
      elsif value.is_a?(Array)
        value.map! { |v| get_deferred(v) }
      elsif value.is_a?(Hash)
        value.each { |k, v| value[k] = get_deferred(v) }
      end

      value
    end

    def deferred?(value)
      value.is_a?(DeferredContextValue)
    end
  end
end
