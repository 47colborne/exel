module EXEL
  module ProcessorHelper

    # Helper Methods

    def tag(*tags)
      tags.map { |t| "[#{ t }]" }.join('')
    end

    def timestamp
      Time.now.strftime('%m/%e/%y %H:%M')
    end

    def file_size_in_mb(file)
      "#{ '%.2f' % (file.size.to_f / 1024000).round(2) } MB"
    end

    # Logging Helpers

    def log_prefix_with(prefix)
      @log_prefix = (@context[:log_prefix] || '') + prefix
    end

    def log_prefix
      @log_prefix
    end

    def log_info(message)
      #FIXME Rails.logger.info(log(message))
    end

    def log_error(message)
      #FIXME Rails.logger.error(log(message))
    end

    def log(message)
      "#{ log_prefix } #{ message }"
    end

    def log_transaction(message = "")
      transaction_start_time = Time.now.to_f
      log_info "Started at #{ Time.now }"
      yield(transaction_start_time)
      transaction_end_time = Time.now.to_f
      log_info "Finished in #{(transaction_end_time - transaction_start_time).to_i} seconds #{ message }"
    end

    def log_exception(message = "")
      yield
    rescue => e
      log_error "Exception: #{ e.message.chomp } #{ message }"
      log_error e.backtrace.join("\n")
      raise e
    end

    def log_process(message = "")
      log_exception(message) { log_transaction(message) { yield } }
    end

    def ensure_transaction_duration(duration, start_time)
      elapsed_time = Time.now.to_f - start_time.to_f
      time_to_sleep = duration.second.to_f - elapsed_time
      sleep(time_to_sleep) if time_to_sleep > 0
    end

  end
end
