# frozen_string_literal: true
module EXEL
  module Middleware
    # Middleware to add a prefix to all messages logged during processor execution. The prefix is specified by the
    # +:log_prefix+ key in the context. Also logs start, finish, and failure of the processor execution.
    class Logging
      def call(processor_class, context, _args, &block)
        EXEL::Logging.with_prefix("#{context[:log_prefix]}[#{processor_class}] ") { log_process(&block) }
      end

      private

      def log_process
        start_time = Time.now
        EXEL.logger.info 'Starting'

        yield

        EXEL.logger.info "Finished in #{duration(start_time)} seconds"
      rescue Exception # rubocop:disable Lint/RescueException
        EXEL.logger.info "Failed in #{duration(start_time)} seconds"
        raise
      end

      def duration(start_time)
        (Time.now - start_time).round(3)
      end
    end
  end
end
