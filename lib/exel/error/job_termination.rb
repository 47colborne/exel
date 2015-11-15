module EXEL
  module Error
    # Inherit from Exception rather then StandardError
    # because rescue => e will only catch StandardError
    # and allow the Exception to propagate to the root
    # of the job
    class JobTermination < Exception
    end
  end
end
