# frozen_string_literal: true
module EXEL
  module Processors
    describe AsyncProcessor do
      subject(:processor) { described_class.new(context) }
      let(:context) { EXEL::Context.new }
      let(:block) { instance_double(SequenceNode) }

      before do
        allow(EXEL).to receive(:async_provider).and_return(EXEL::Providers::DummyAsyncProvider)
      end

      it 'looks up the async provider on initialization' do
        expect(processor.provider).to be_an_instance_of(EXEL::Providers::DummyAsyncProvider)
      end

      describe '#process' do
        it 'calls do_async on the async provider' do
          expect(processor.provider).to receive(:do_async).with(block)
          processor.process(block)
        end
      end
    end
  end
end
