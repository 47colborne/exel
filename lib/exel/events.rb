# frozen_string_literal: true
module EXEL
  # Provides methods for registering and triggering event listeners
  module Events
    LISTENERS_KEY = :_listeners

    def register_listener(context, event, listener)
      listeners_for_event(event, context) << listener
    end

    def trigger(event, data = {})
      listeners_for_event(event, context).each { |listener| listener.send(event, context, data) }
    end

    def self.included(other)
      other.class_eval { attr_reader :context }
    end

    private

    def listeners_for_event(event, context)
      listeners(context).fetch(event)
    rescue KeyError
      listeners(context)[event] = []
    end

    def listeners(context)
      context[LISTENERS_KEY] ||= Hash.new([])
    end
  end
end
