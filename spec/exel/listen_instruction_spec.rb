module EXEL
  describe ListenInstruction do
    subject(:instruction) { EXEL::ListenInstruction.new(:event, listener) }
    let(:listener) { double(:listener) }
    let(:context) { EXEL::Context.new }

    describe '#execute' do
      it 'registers the event listener' do
        instruction.execute(context)
        expect(context[:_listeners].fetch(:event)).to contain_exactly(listener)
      end
    end
  end
end
