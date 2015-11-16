require 'logger'

module EXEL
  module Logging
    def self.logger
      @logger
    end

    def self.logger=(logger)
      @logger = logger || Logger.new('/dev/null')
    end
  end
end