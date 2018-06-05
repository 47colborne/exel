# frozen_string_literal: true

describe EXEL::Logging do
  before { @restore_logger = EXEL::Logging.logger }
  after { EXEL::Logging.logger = @restore_logger }

  describe EXEL::Logging::PrefixFormatter do
    context 'without a Logging prefix' do
      it 'formats the message' do
        expect(subject.call('warn', Time.new(2007, 11, 1, 15, 25, 0, '+09:00'), 'test', 'message'))
            .to eq("2007-11-01 06:25:00 UTC severity=warn, message\n")
      end
    end

    context 'with a Logging prefix' do
      it 'adds the prefix to the formatted message' do
        EXEL::Logging.with_prefix('[prefix] ') do
          expect(subject.call('warn', Time.new(2007, 11, 1, 15, 25, 0, '+09:00'), 'test', 'message'))
              .to eq("2007-11-01 06:25:00 UTC severity=warn, [prefix] message\n")
        end
      end
    end
  end

  describe '.logger=' do
    it 'sets a wrapped logger' do
      logger = instance_double(Logger)
      EXEL::Logging.logger = logger
      expect(EXEL::Logging.logger).to be_a(EXEL::Logging::LoggerWrapper)
      expect(EXEL::Logging.logger.__getobj__).to be(logger)
    end

    it 'sets a null logger when nil given' do
      expect(Logger).to receive(:new).with('/dev/null')
      EXEL::Logging.logger = nil
    end
  end

  describe '.logger' do
    before { EXEL::Logging.instance_variable_set(:@logger, nil) }

    it 'initializes the logger on first read if not already set' do
      EXEL.configure do |config|
        config.log_level = :warn
        config.log_filename = 'log.txt'
      end

      logger = instance_double(Logger)
      expect(Logger).to receive(:new).with('log.txt').and_return(logger)
      expect(logger).to receive(:level=).with(Logger::WARN)
      expect(logger).to receive(:formatter=).with(EXEL::Logging::PrefixFormatter)

      EXEL::Logging.logger
    end
  end

  describe '.with_prefix' do
    it 'sets the prefix before yielding to the block and clears it after' do
      expect(EXEL::Logging.prefix).to be_nil

      EXEL::Logging.with_prefix('testing') do
        expect(EXEL::Logging.prefix).to eq('testing')
      end

      expect(EXEL::Logging.prefix).to be_nil
    end

    it 'handles nesting' do
      EXEL::Logging.with_prefix('outer') do
        expect(EXEL::Logging.prefix).to eq('outer')

        EXEL::Logging.with_prefix('inner') do
          expect(EXEL::Logging.prefix).to eq('inner')
        end

        expect(EXEL::Logging.prefix).to eq('outer')
      end
    end
  end
end
