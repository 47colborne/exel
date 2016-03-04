module EXEL
  describe ASTNode do
    let(:context) { instance_double(EXEL::Context) }

    def instruction
      instance_double(Instruction, execute: nil)
    end

    TestNode = Class.new(ASTNode)

    describe '#start' do
      context 'when an JobTermination error bubbles up' do
        it 'should ensure the process fails silently' do
          node = TestNode.new(instruction)
          allow(node).to receive(:run).and_raise(EXEL::Error::JobTermination, 'Error')
          expect(EXEL.logger).to receive(:error).with('JobTerminationError: Error')
          expect { node.start(context) }.not_to raise_error
        end
      end
    end

    describe '#run' do
      it 'should raise an error if not implemented' do
        expect { TestNode.new(instruction).run(context) }.to raise_error 'EXEL::TestNode does not implement #process'
      end
    end

    describe '#add_child' do
      it 'should add the given node to its children' do
        root = ASTNode.new(instruction)
        child_node = ASTNode.new(instruction)
        child_node2 = ASTNode.new(instruction)
        root.add_child(child_node)
        root.add_child(child_node2)

        expect(root.children).to eq([child_node, child_node2])
      end
    end
  end
end
