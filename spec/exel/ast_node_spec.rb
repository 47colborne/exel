module EXEL
  describe ASTNode do
    let(:context) { instance_double(EXEL::Context) }

    def instruction
      instance_double(Instruction, execute: nil)
    end

    TestNode = Class.new(ASTNode)

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
        expect { TestNode.new(instruction).run(context) }.to raise_error 'EXEL::TestNode does not implement #process'
      end
    end

    describe '#add_child' do
      it 'adds the given node to its children' do
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
