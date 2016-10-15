# frozen_string_literal: true
module EXEL
  module Error
    # If a processor raises a JobTermination exception, the job will immediately stop running without raising anything.
    # This is useful if you want to stop a job without triggering any kind of retry mechanism, for example.
    class JobTermination < Exception # Inherit from Exception so it won't be rescued and can propagate to ASTNode#start
      attr_reader :cmd

      CMDS = [:info, :warn, :error].freeze

      def initialize(message, cmd = :error)
        super(message)
        @cmd = CMDS.include?(cmd) ? cmd : :error
      end
    end
  end
end
