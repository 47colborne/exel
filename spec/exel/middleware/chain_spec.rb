# frozen_string_literal: true
module EXEL
  module Middleware
    describe Chain do
      subject(:chain) { EXEL::Middleware::Chain.new }

      class TestMiddleware
        def initialize(*)
        end

        def call
        end
      end

      AnotherTestMiddleware = Class.new(TestMiddleware)

      describe '#add' do
        it 'adds a middleware to the chain' do
          chain.add(TestMiddleware)
          expect(chain).to include(TestMiddleware)
        end

        it 'removes and adds to end if already present' do
          chain.add(TestMiddleware)
          chain.add(AnotherTestMiddleware)
          chain.add(TestMiddleware)
          expect(chain.entries.map(&:klass)).to eq([AnotherTestMiddleware, TestMiddleware])
        end
      end

      describe '#remove' do
        it 'removes a middleware from the chain' do
          chain.add(TestMiddleware)
          chain.add(AnotherTestMiddleware)
          chain.remove(TestMiddleware)
          expect(chain.entries.map(&:klass)).to eq([AnotherTestMiddleware])
        end
      end

      describe '#include?' do
        it 'returns true if the middleware class is in the chain' do
          chain.add(TestMiddleware)
          expect(chain).to include(TestMiddleware)
        end

        it 'returns false if the middleware class is not in the chain' do
          chain.add(TestMiddleware)
          expect(chain).not_to include(AnotherTestMiddleware)
        end
      end

      describe '#invoke' do
        it 'calls each middleware' do
          chain.add(TestMiddleware)
          expect_any_instance_of(TestMiddleware).to receive(:call).with(1, 2, 3)
          chain.invoke(1, 2, 3)
        end

        it 'initializes middleware with given constructor arguments' do
          chain.add(TestMiddleware, 1, 2)
          expect(TestMiddleware).to receive(:new).with(1, 2).and_return(TestMiddleware.new)
          chain.invoke
        end
      end
    end
  end
end
