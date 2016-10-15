# frozen_string_literal: true
require 'exel/version'
require 'exel/logging'
require 'ostruct'

# Provides methods to configure EXEL
module EXEL
  # @return The currently set logger
  def self.logger
    EXEL::Logging.logger
  end

  # Sets the logger to be used.
  #
  # @param [Logger] The logger to set. Must comply with the Ruby Logger interface
  def self.logger=(logger)
    EXEL::Logging.logger = logger
  end

  # @return The current configuration
  def self.configuration
    @config ||= OpenStruct.new
  end

  # Yields the configuration object to the given block. Configuration can include:
  # * +async_provider+ Set an async provider. Defaults to EXEL::Providers::ThreadedAsyncProvider
  # * +remote_provider+ Set a remote provider. Defaults to EXEL::Providers::LocalFileProvider
  # * Any configuration required by the async/remote providers
  #
  # Typically, async_provider and remote_provider will be automatically set upon requiring those gems.
  #
  # Example:
  #   EXEL.configure do |config|
  #     config.s3_bucket = 'my_bucket'
  #   end
  def self.configure
    yield configuration
  end

  # @return The currently configured async provider. Defaults to EXEL::Providers::ThreadedAsyncProvider
  def self.async_provider
    configuration.async_provider || Providers::ThreadedAsyncProvider
  end

  # @return The currently configured remote provider. Defaults to EXEL::Providers::LocalFileProvider
  def self.remote_provider
    configuration.remote_provider || Providers::LocalFileProvider
  end

  root = File.expand_path('../..', __FILE__)
  Dir[File.join(root, 'lib/exel/**/*.rb')].each { |file| require file }
end
