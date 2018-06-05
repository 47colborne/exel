# frozen_string_literal: true

describe EXEL::InstructionNode do
  subject(:node) { EXEL::InstructionNode.new(instruction, children: [child]) }

  let(:context) { {} }
  let(:instruction) { instance_double(EXEL::Instruction, execute: nil) }
  let(:child) { instance_double(EXEL::ASTNode) }

  it { is_expected.to be_kind_of(EXEL::ASTNode) }

  describe '#run' do
    it 'only executes the instruction' do
      expect(instruction).to receive(:execute).with(context).once
      node.run(context)
    end

    it 'does not run it`s children' do
      expect(child).not_to receive(:run)
      node.run(context)
    end
  end
end
