module EXEL
  describe SequenceNode do
    let(:context) { {} }

    def build_tree
      @node_2 = instance_double(ASTNode)
      @node_3 = instance_double(ASTNode)
      @node_1 = SequenceNode.new(@node_2, @node_3)
    end

    it { is_expected.to be_kind_of(ASTNode) }

    describe '#run' do
      before { build_tree }

      it 'should run each child node in sequence' do
        expect(@node_2).to receive(:run).with(context).once.ordered
        expect(@node_3).to receive(:run).with(context).once.ordered

        @node_1.run(context)
      end
    end
  end
end
