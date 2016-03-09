module EXEL
  describe Events do
    class EventTest
      include Events
    end

    subject(:events) { EventTest.new }

    let(:event_listener) { double(:event_listener) }
    let(:context) { EXEL::Context.new(_listeners: {test_event: [event_listener]}) }
    let(:data) { {foo: 1} }

    before { allow(events).to receive(:context).and_return(context) }

    describe '#trigger' do
      context 'when no events have been registered' do
        let(:context) { EXEL::Context.new }

        it 'does not trigger anything' do
          expect(event_listener).not_to receive(:test_event)

          events.trigger(:test_event, data)
        end
      end

      context 'with a single listener registered for the event' do
        it 'calls the listener with the context and event data' do
          expect(event_listener).to receive(:test_event).with(context, data)

          events.trigger(:test_event, data)
        end

        it 'passes an empty hash if no data was given' do
          expect(event_listener).to receive(:test_event).with(context, {})

          events.trigger(:test_event)
        end
      end

      context 'with no listeners registered for the event' do
        let(:context) { EXEL::Context.new(_listeners: {other_event: [event_listener]}) }

        it 'does not trigger anything' do
          expect(event_listener).not_to receive(:test_event)

          events.trigger(:test_event, data)
        end
      end

      context 'with multiple listeners registered for the event' do
        let(:event_listener2) { double(:event_listener2) }
        let(:context) { EXEL::Context.new(_listeners: {test_event: [event_listener, event_listener2]}) }

        it 'calls each listener with the context and event data' do
          expect(event_listener).to receive(:test_event).with(context, data)
          expect(event_listener2).to receive(:test_event).with(context, data)

          events.trigger(:test_event, data)
        end
      end
    end
  end
end
