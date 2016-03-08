module EXEL
  # Registers an event listener
  class ListenInstruction
    def initialize(event, listener)
      @event = event
      @listener = listener
    end

    def execute(context)
      listeners = initialize_listeners(context)
      listeners[@event] << @listener
    end

    private

    def initialize_listeners(context)
      context[:_listeners] ||= {}
      context[:_listeners][@event] ||= []
      context[:_listeners]
    end
  end
end
