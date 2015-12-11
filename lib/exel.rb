require 'exel/version'
require 'exel/logging'
require 'ostruct'

module EXEL
  def self.logger
    EXEL::Logging.logger
  end

  def self.logger=(logger)
    EXEL::Logging.logger = logger
  end

  def self.configuration
    @config ||= OpenStruct.new
  end

  def self.configure
    yield configuration
  end

  def self.async_provider
    configuration.async_provider || Providers::LocalAsyncProvider
  end

  root = File.expand_path('../..', __FILE__)
  Dir[File.join(root, 'lib/exel/**/*.rb')].each { |file| require file }
end
