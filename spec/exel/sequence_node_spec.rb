module EXEL
  describe SequenceNode do
    subject(:node) { described_class.new(instance_double(ASTNode), instance_double(ASTNode)) }
    let(:context) { instance_double(EXEL::Context) }

    it { is_expected.to be_an(ASTNode) }

    describe '#run' do
      it 'should run each child node in sequence' do
        expect(node.children.first).to receive(:run).with(context).once.ordered
        expect(node.children.last).to receive(:run).with(context).once.ordered

        node.run(context)
      end
    end
  end
end
