# frozen_string_literal: true

describe EXEL::Middleware::Logging do
  class TestProcessor
  end

  describe '#call' do
    it 'yields to the given block' do
      called = false

      subject.call(Object, {}, {}) do
        called = true
      end

      expect(called).to be_truthy
    end

    it 'logs with context[:log_prefix] and the processor class as the prefix' do
      expect(EXEL::Logging).to receive(:with_prefix).with('[prefix][TestProcessor] ')
      subject.call(TestProcessor, {log_prefix: '[prefix]'}, {}) {}
    end

    it 'raises rescued exceptions' do
      expect do
        subject.call(Object, {}, {}) do
          raise Exception, 're-raise me'
        end
      end.to raise_error Exception, 're-raise me'
    end
  end
end
