module EXEL
  module Providers
    class ContextMutatingProcessor
      def initialize(context)
        @context = context
      end

      def process(_block)
        @context[:array] << @context[:arg]
      end
    end

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

        it 'passes a copy of the context to each thread' do
          context[:array] = []
          complete = 0

          EXEL::Job.define :thread_test do
            async do
              process with: ContextMutatingProcessor, arg: 1
              complete += 1
            end

            async do
              process with: ContextMutatingProcessor, arg: 2
              complete += 1
            end
          end

          EXEL::Job.run(:thread_test, context)

          start_time = Time.now
          sleep 0.1 while complete < 2 && Time.now - start_time < 2

          expect(context[:array]).to be_empty
        end
      end
    end
  end
end
