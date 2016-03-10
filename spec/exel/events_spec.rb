module EXEL
  describe Events do
    class EventTest
      include Events
    end

    subject(:events) { EventTest.new }
    let(:event_listener) { double(:event_listener) }
    let(:context) { EXEL::Context.new(Events::LISTENERS_KEY => {event: [event_listener]}) }

    describe '#register_listener' do
      context 'when no listeners have been defined' do
        let(:context) { EXEL::Context.new }

        it 'adds a new listener to the context' do
          events.register_listener(context, :event, event_listener)
          expect(context[Events::LISTENERS_KEY].fetch(:event)).to contain_exactly(event_listener)
        end
      end

      it 'registers multiple listeners for the same event' do
        new_listener = double(:event_listener2)
        events.register_listener(context, :event, new_listener)
        expect(context[Events::LISTENERS_KEY].fetch(:event)).to contain_exactly(event_listener, new_listener)
      end
    end

    describe '#trigger' do
      let(:context) { EXEL::Context.new }
      let(:data) { {foo: 1} }

      before { allow(events).to receive(:context).and_return(context) }

      context 'when no events have been registered' do
        it 'does not trigger anything' do
          expect(event_listener).not_to receive(:event)

          events.trigger(:event, data)
        end
      end

      context 'with a single listener registered for the event' do
        before do
          events.register_listener(context, :event, event_listener)
        end

        it 'calls the listener with the context and event data' do
          expect(event_listener).to receive(:event).with(context, data)

          events.trigger(:event, data)
        end

        it 'passes an empty hash if no data was given' do
          expect(event_listener).to receive(:event).with(context, {})

          events.trigger(:event)
        end
      end

      context 'with no listeners registered for the event' do
        before do
          events.register_listener(context, :other_event, event_listener)
        end

        it 'does not trigger anything' do
          expect(event_listener).not_to receive(:event)

          events.trigger(:event, data)
        end
      end

      context 'with multiple listeners registered for the event' do
        let(:event_listener2) { double(:event_listener2) }

        before do
          events.register_listener(context, :event, event_listener)
          events.register_listener(context, :event, event_listener2)
        end

        it 'calls each listener with the context and event data' do
          expect(event_listener).to receive(:event).with(context, data)
          expect(event_listener2).to receive(:event).with(context, data)

          events.trigger(:event, data)
        end
      end
    end
  end
end
