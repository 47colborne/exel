module EXEL
  describe ListenInstruction do
    subject(:instruction) { EXEL::ListenInstruction.new(:event, listener) }
    let(:listener) { double(:listener) }
    let(:context) { EXEL::Context.new }

    describe '#execute' do
      it 'registers the event listener' do
        expect(instruction).to receive(:register_listener).with(context, :event, listener)
        instruction.execute(context)
      end
    end
  end
end
