module EXEL
  module Processors
    describe AsyncProcessor do
      subject(:processor) { AsyncProcessor.new(context) }
      let(:context) { EXEL::Context.new }
      let(:block) { instance_double(SequenceNode) }

      describe '#process' do
        it 'should call do_async on the async handler' do
          expect(processor.handler).to receive(:do_async).with(block)
          processor.process(block)
        end
      end
    end
  end
end