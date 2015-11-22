require 'exel/version'
require 'exel/logging'

module EXEL
  def self.logger
    EXEL::Logging.logger
  end

  def self.logger=(logger)
    EXEL::Logging.logger = logger
  end

  def self.configuration
    @config ||= {}
  end

  def self.configure
    yield configuration
  end

  root = File.expand_path('../..', __FILE__)
  Dir[File.join(root, 'lib/exel/**/*.rb')].each { |file| require file }
end
