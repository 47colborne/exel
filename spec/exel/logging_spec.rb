module EXEL
  describe Logging do
    before { @restore_logger = Logging.logger }
    after { Logging.logger = @restore_logger }

    describe '.logger=' do
      it 'sets a logger' do
        logger = double(:logger)
        Logging.logger = logger
        expect(Logging.logger).to be(logger)
      end

      it 'sets a null logger when nil given' do
        expect(Logger).to receive(:new).with('/dev/null')
        Logging.logger = nil
      end
    end

    describe '.logger' do
      before { Logging.instance_variable_set(:@logger, nil) }

      it 'initializes the logger on first read if not already set' do
        EXEL.configure do |config|
          config.log_level = :warn
          config.log_filename = 'log.txt'
        end

        logger = instance_double(Logger)
        expect(Logger).to receive(:new).with('log.txt').and_return(logger)
        expect(logger).to receive(:level=).with(Logger::WARN)

        Logging.logger
      end
    end
  end
end
