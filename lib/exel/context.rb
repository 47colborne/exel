# frozen_string_literal: true
require 'tempfile'
require 'securerandom'

module EXEL
  # The +Context+ is the shared memory of a running job. It acts as the source of input to processors and the place for
  # them to store their outputs. It can be serialized and deserialized to support remote execution.
  class Context < Hash
    # Accepts an optional hash of keys and values to initialize the context with.
    def initialize(initial_context = {})
      super()
      merge!(initial_context)
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

      begin
        context = Marshal.load(file.read)
      ensure
        file.close
      end

      context
    end

    # Returns the value referenced by the given key. If it is a remote value, it will be converted to a local value and
    # the local value will be returned.
    def [](key)
      convert_value!(key, super(key))
    end

    def fetch(key)
      convert_value!(key, super(key))
    end

    private

    def serialized_context
      file = Tempfile.new(SecureRandom.uuid, encoding: 'ascii-8bit')
      file.write(Marshal.dump(Context.new(remotized_table)))
      file.rewind
      file
    end

    def remotized_table
      each_with_object({}) { |(key, value), acc| acc[key] = EXEL::Value.remotize(value) }
    end

    def convert_value!(key, value)
      value = EXEL::Value.localize(value)
      value = DeferredContextValue.resolve(value, self)
      self[key] = value
    end
  end
end
