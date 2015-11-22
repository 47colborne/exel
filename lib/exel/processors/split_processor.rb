require 'csv'
require 'tempfile'
require_relative '../processor_helper'

module EXEL
  module Processors
    class SplitProcessor
      include EXEL::ProcessorHelper

      attr_accessor :chunk_size, :file_name, :block

      DEFAULT_CHUNK_SIZE = 1000

      def initialize(context)
        @chunk_size = DEFAULT_CHUNK_SIZE
        @buffer = []
        @tempfile_count = 0
        @context = context

        @file = context[:resource]
        @file_name = filename(@file)
        @csv_options = context[:csv_options] || {col_sep: ','}

        log_prefix_with '[SplitProcessor]'
      end

      def process(callback)
        log_process do
          begin
            CSV.foreach(@file.path, @csv_options) do |line|
              process_line(line, callback)
            end
          rescue CSV::MalformedCSVError => e
            log_error "CSV::MalformedCSVError => #{e.message}"
          end
          process_line(:eof, callback)
          File.delete(@file.path)
        end
      end

      def process_line(line, callback)
        if line == :eof
          flush_buffer callback
        else
          @buffer << CSV.generate_line(line)

          flush_buffer callback if buffer_full?
        end
      end

      def generate_chunk(content)
        @tempfile_count += 1
        chunk = Tempfile.new([chunk_filename, '.csv'])
        chunk.write(content)
        chunk.rewind

        log_info "Generated chunk # #{@tempfile_count} for file #{@file_name} in #{chunk.path}"
        chunk
      end

      def chunk_filename
        "#{@file_name}_#{@tempfile_count}_"
      end

      def filename(file)
        file_name_with_extension = file.path.split('/').last
        file_name_with_extension.split('.').first
      end

      private

      def flush_buffer(callback)
        unless @buffer.empty?
          file = generate_chunk(@buffer.join(''))
          callback.run(@context.merge!(resource: file))
        end
        @buffer = []
      end

      def buffer_full?
        @buffer.size == @chunk_size
      end
    end
  end
end
