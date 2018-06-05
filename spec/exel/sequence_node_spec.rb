# frozen_string_literal: true

describe EXEL::SequenceNode do
  subject(:node) { described_class.new(instance_double(EXEL::ASTNode), instance_double(EXEL::ASTNode)) }

  let(:context) { instance_double(EXEL::Context) }

  it { is_expected.to be_an(EXEL::ASTNode) }

  describe '#run' do
    it 'runs each child node in sequence' do
      expect(node.children.first).to receive(:run).with(context).once.ordered
      expect(node.children.last).to receive(:run).with(context).once.ordered

      node.run(context)
    end
  end
end
