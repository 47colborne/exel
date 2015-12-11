module EXEL
  module Providers
    describe ThreadedAsyncProvider do
      subject { described_class.new(context) }
      let(:context) { EXEL::Context.new }

      describe '#do_async' do
        let(:dsl_block) { instance_double(ASTNode) }

        it 'runs the block in a new thread' do
          expect(dsl_block).to receive(:start).with(context)
          expect(Thread).to receive(:new).and_yield

          subject.do_async(dsl_block)
        end
      end
    end
  end
end
