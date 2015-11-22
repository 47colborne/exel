module EXEL
  module Handlers
    describe SidekiqHandler do
      subject(:handler) { SidekiqHandler.new(context) }
      let(:callback) { instance_double(SequenceNode) }
      let(:context) { EXEL::Context.new }
      let(:serialized_context_uri) { 'context_uri' }

      describe '#do_async' do
        before do
          allow(context).to receive(:serialize).and_return(serialized_context_uri)
        end

        it 'should add the callback to the context before serializing it' do
          expect(context).to receive(:[]=).with(:_block, callback).ordered
          expect(context).to receive(:serialize).ordered
          handler.do_async(callback)
        end

        context 'with queue name' do
          let(:context) { EXEL::Context.new(queue: 'import_processor') }

          it 'should push the execution worker to the given queue' do
            expect(Sidekiq::Client).to receive(:push).with('queue' => context[:queue], 'class' => ExecutionWorker, 'args' => [serialized_context_uri])
            handler.do_async(callback)
          end
        end

        context 'without queue name' do
          it 'should push the execution worker to the default queue' do
            expect(Sidekiq::Client).to receive(:push).with('class' => ExecutionWorker, 'args' => [serialized_context_uri])
            handler.do_async(callback)
          end
        end

        context 'with retries specified' do
          let(:context) { EXEL::Context.new(retry: 1) }

          it 'should push the execution worker with a specified number of retries' do
            expect(Sidekiq::Client).to receive(:push).with('retry' => context[:retry], 'class' => ExecutionWorker, 'args' => [serialized_context_uri])
            handler.do_async(callback)
          end
        end

        context 'with no retries specified' do
          it 'should push the execution worker with no specified number of retries' do
            expect(Sidekiq::Client).to receive(:push).with('class' => ExecutionWorker, 'args' => [serialized_context_uri])
            handler.do_async(callback)
          end
        end
      end
    end
  end
end
