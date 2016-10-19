# frozen_string_literal: true
module EXEL
  module Logging
    # Wraps calls to a logger to add {Logging} prefix to log messages
    class LoggerWrapper < SimpleDelegator
      LOG_LEVELS = %i(debug info warn error fatal unknown).freeze

      LOG_LEVELS.each do |level|
        define_method level do |progname = nil, &block|
          prefix_block = nil

          if block
            prefix_block = proc { "#{Logging.prefix}#{block.call}" }
          else
            progname = "#{Logging.prefix}#{progname}"
          end

          __getobj__.send(level, progname, &prefix_block)
        end
      end

      def add(severity, message = nil, progname = nil)
        message = yield if message.nil? && block_given?
        __getobj__.add(severity, "#{Logging.prefix}#{message}", progname)
      end
    end
  end
end
