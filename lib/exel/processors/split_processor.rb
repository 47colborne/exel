# frozen_string_literal: true
require 'csv'
require 'tempfile'
require_relative '../logging_helper'

module EXEL
  module Processors
    # Implements the +split+ instruction. Used to concurrently process a large file by splitting it into small chunks to
    # be separately processed.
    #
    # =Supported Context Options
    # * +:delete_resource+ Defaults to true, can be set to false to preserve the original resource. Otherwise, it will
    #   be deleted when splitting is complete
    # * +:chunk_size+ Set to specify the number of lines that each chunk should contain
    class SplitProcessor
      include EXEL::LoggingHelper

      attr_accessor :file_name, :block

      # Number of lines to include in each chunk. Can be overridden by setting :chunk_size in the context
      DEFAULT_CHUNK_SIZE = 1000

      # The context must contain a CSV File object in context[:resource]
      def initialize(context)
        @buffer = []
        @tempfile_count = 0
        @context = context
        @file = context[:resource]
        @max_chunks = @context[:max_chunks] || Float::INFINITY
        @context[:delete_resource] = true if @context[:delete_resource].nil?
      end

      def process(callback)
        process_file(callback)
        finish(callback)
      end

      def process_line(line, callback)
        if line == :eof
          flush_buffer(callback)
        else
          @buffer << CSV.generate_line(line)

          flush_buffer(callback) if buffer_full?
        end
      end

      def generate_chunk(content)
        @tempfile_count += 1
        chunk = Tempfile.new([chunk_filename, '.csv'])
        chunk.write(content)
        chunk.rewind

        log_info "Generated chunk # #{@tempfile_count} for file #{filename(@file)} in #{chunk.path}"
        chunk
      end

      private

      def process_file(callback)
        csv_options = @context[:csv_options] || {col_sep: ','}

        CSV.foreach(@file.path, csv_options) do |line|
          process_line(line, callback)

          break if @tempfile_count == @max_chunks
        end
      rescue CSV::MalformedCSVError => e
        log_error "CSV::MalformedCSVError => #{e.message}"
      end

      def flush_buffer(callback)
        unless @buffer.empty?
          file = generate_chunk(@buffer.join(''))
          callback.run(@context.merge!(resource: file))
        end

        @buffer = []
      end

      def buffer_full?
        @buffer.size == chunk_size
      end

      def chunk_size
        @context[:chunk_size] || DEFAULT_CHUNK_SIZE
      end

      def chunk_filename
        "#{filename(@file)}_#{@tempfile_count}_"
      end

      def filename(file)
        file_name_with_extension = file.path.split('/').last
        file_name_with_extension.split('.').first
      end

      def finish(callback)
        process_line(:eof, callback)
        File.delete(@file.path) if @context[:delete_resource]
      end
    end
  end
end
