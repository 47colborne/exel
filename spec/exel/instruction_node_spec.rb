module EXEL
  describe InstructionNode do
    let(:context) { {} }
    let(:instruction) { instance_double(Instruction, execute: nil) }
    let(:child) { instance_double(ASTNode) }
    subject(:node) { InstructionNode.new(instruction, [child]) }

    it { is_expected.to be_kind_of(ASTNode) }

    describe '#run' do
      it 'should only execute the instruction' do
        expect(instruction).to receive(:execute).with(context).once
        node.run(context)
      end

      it 'should not run it`s children' do
        expect(child).to_not receive(:run)
        node.run(context)
      end
    end
  end
end
