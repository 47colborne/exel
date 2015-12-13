require 'logger'

module EXEL
  module Logging
    DEFAULT_LEVEL = :info

    def self.logger
      @logger || initialize_logger
    end

    def self.initialize_logger
      @logger = Logger.new(log_filename)
      @logger.level = log_level
      @logger
    end

    def self.log_filename
      EXEL.configuration.log_filename || '/dev/null'
    end

    def self.log_level
      level = EXEL.configuration.log_level || DEFAULT_LEVEL
      Logger.const_get(level.to_s.upcase)
    end

    def self.logger=(logger)
      @logger = logger || Logger.new('/dev/null')
    end
  end
end
