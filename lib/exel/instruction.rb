module EXEL
  # Represents one step to be executed in the processing of a job
  class Instruction
    def initialize(processor_class, args, subtree = nil)
      @processor_class = processor_class
      @args = args || {}
      @subtree = subtree
    end

    def execute(context)
      context.merge!(@args)
      @processor_class.new(context).process(@subtree)
    end
  end
end
