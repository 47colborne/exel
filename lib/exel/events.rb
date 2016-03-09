module EXEL
  # Provides a #trigger method to call registered listeners for an event.
  module Events
    def trigger(event, data = {})
      listeners = context[:_listeners]
      return unless listeners

      event_listeners = listeners[event]
      event_listeners.each { |listener| listener.send(event, context, data) } if event_listeners
    end
  end
end
