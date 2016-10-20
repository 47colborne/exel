# frozen_string_literal: true
require 'logger'

module EXEL
  module Logging
    DEFAULT_LEVEL = :info

    # Formats log messages with timestamp, severity and Logging prefix (if set via {Logging.with_prefix})
    class PrefixFormatter < Logger::Formatter
      def call(severity, time, _program_name, message)
        "#{time.utc} severity=#{severity}, #{Logging.prefix}#{message}\n"
      end
    end

    def self.logger
      @logger || initialize_logger
    end

    def self.initialize_logger
      @logger = Logger.new(log_filename)
      @logger.level = log_level
      @logger.formatter = PrefixFormatter.new
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
      @logger = logger ? LoggerWrapper.new(logger) : Logger.new('/dev/null')
    end

    # Sets a prefix to be added to any messages sent to the EXEL logger in the given block.
    def self.with_prefix(prefix)
      Thread.current[:exel_log_prefix] = prefix
      yield
    ensure
      Thread.current[:exel_log_prefix] = nil
    end

    def self.prefix
      Thread.current[:exel_log_prefix]
    end
  end
end
