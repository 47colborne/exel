# frozen_string_literal: true
module EXEL
  # An {Instruction} that does nothing when executed
  class NullInstruction
    def execute(context)
    end
  end
end
