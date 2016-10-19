# frozen_string_literal: true
module EXEL
  module Logging
    describe LoggerWrapper do
      subject(:wrapper) { LoggerWrapper.new(logger) }
      let(:logger) { instance_double(Logger) }

      it { is_expected.to be_a(SimpleDelegator) }

      LOG_LEVELS = %i(debug info warn error fatal unknown).freeze

      context 'without a Logging prefix' do
        LOG_LEVELS.each do |level|
          describe "##{level}" do
            context 'when passed a message string' do
              it 'passes the message to its wrapped logger' do
                expect(logger).to receive(level).with('message')
                wrapper.send(level, 'message')
              end
            end

            context 'when passed a message block' do
              it 'passes the block to its wrapped logger' do
                block = proc {}
                expect(logger).to receive(level).with(nil, &block)

                wrapper.send(level, &block)
              end

              context 'and a progname' do
                it 'passes the block and progname to its wrapped logger' do
                  block = proc {}
                  expect(logger).to receive(level).with('test', &block)

                  wrapper.send(level, 'test', &block)
                end
              end
            end
          end
        end

        describe '#add' do
          it 'passes the message to its wrapped logger' do
            expect(logger).to receive(:add).with(Logger::FATAL, 'message', 'progname')
            wrapper.add(Logger::FATAL, 'message', 'progname')
          end
        end
      end

      context 'with a Logging prefix' do
        before { allow(Logging).to receive(:prefix).and_return('prefix: ') }

        LOG_LEVELS.each do |level|
          describe "##{level}" do
            context 'when passed a message string' do
              it 'passes the prefixed message to its wrapped logger' do
                expect(logger).to receive(level).with('prefix: message')
                wrapper.send(level, 'message')
              end
            end

            context 'when passed a message block' do
              it 'passes the prefixed block to its wrapped logger' do
                expect(logger).to receive(level) do |progname, &block|
                  expect(progname).to be_nil
                  expect(block.call).to eq('prefix: message')
                end

                wrapper.send(level) { 'message' }
              end

              context 'and a progname' do
                it 'passes the prefixed block and progname to its wrapped logger' do
                  expect(logger).to receive(level) do |progname, &block|
                    expect(progname).to eq('test')
                    expect(block.call).to eq('prefix: message')
                  end

                  wrapper.send(level, 'test') { 'message' }
                end
              end
            end
          end
        end

        describe '#add' do
          it 'passes the prefixed message to its wrapped logger' do
            expect(logger).to receive(:add).with(Logger::FATAL, 'prefix: message', 'progname')
            wrapper.add(Logger::FATAL, 'message', 'progname')
          end
        end
      end
    end
  end
end
