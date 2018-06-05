# frozen_string_literal: true

require_relative 'events'

module EXEL
  # Registers an event listener
  class ListenInstruction
    include EXEL::Events

    def initialize(event, listener)
      @event = event
      @listener = listener
    end

    def execute(context)
      register_listener(context, @event, @listener)
    end
  end
end
