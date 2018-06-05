# frozen_string_literal: true

describe EXEL::ASTNode do
  let(:context) { instance_double(EXEL::Context) }

  def instruction
    instance_double(EXEL::Instruction, execute: nil)
  end

  class TestNode < EXEL::ASTNode
  end

  describe '#start' do
    context 'when a JobTermination error bubbles up' do
      let(:node) { TestNode.new(instruction) }

      before do
        allow(node).to receive(:run).and_raise(EXEL::Error::JobTermination, 'Error')
      end

      it 'ensures the process fails silently' do
        expect(EXEL.logger).to receive(:error).with('JobTerminationError: Error')
        expect { node.start(context) }.not_to raise_error
      end

      it 'logs the error by default' do
        expect(EXEL.logger).to receive(:error).with('JobTerminationError: Error')
        node.start(context)
      end

      context 'given a log instruction' do
        before do
          allow(node).to receive(:run).and_raise(EXEL::Error::JobTermination.new('Error', :warn))
        end

        it 'logs the error with the given cmd' do
          expect(EXEL.logger).to receive(:warn).with('JobTerminationError: Error')
          node.start(context)
        end
      end
    end
  end

  describe '#run' do
    it 'raises an error if not implemented' do
      expect { TestNode.new(instruction).run(context) }.to raise_error 'TestNode does not implement #process'
    end
  end

  describe '#add_child' do
    it 'adds the given node to its children' do
      root = EXEL::ASTNode.new(instruction)
      child_node = EXEL::ASTNode.new(instruction)
      child_node2 = EXEL::ASTNode.new(instruction)
      root.add_child(child_node)
      root.add_child(child_node2)

      expect(root.children).to eq([child_node, child_node2])
    end
  end
end
