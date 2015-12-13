module EXEL
  class Instruction
    attr_reader :name

    def initialize(name, processor_class, args, subtree = nil)
      @name = name
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
