require 'exel/version'
require 'exel/logging'

module EXEL
  def self.logger
    EXEL::Logging.logger
  end

  def self.logger=(logger)
    EXEL::Logging.logger = logger
  end
end
