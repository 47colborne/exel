# frozen_string_literal: true
module EXEL
  # Logging related helper methods for processors
  module LoggingHelper
    # @return [Logger] Returns the EXEL logger
    def logger
      EXEL.logger
    end

    # Logs a message with DEBUG severity
    def log_debug(message)
      logger.debug(message)
    end

    # Logs a message with INFO severity
    def log_info(message)
      logger.info(message)
    end

    # Logs a message with WARN severity
    def log_warn(message)
      logger.warn(message)
    end

    # Logs a message with ERROR severity
    def log_error(message)
      logger.error(message)
    end

    # Logs a message with FATAL severity
    def log_fatal(message)
      logger.fatal(message)
    end
  end
end
