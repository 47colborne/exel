module EXEL
  class ASTNode
    attr_reader :instruction, :children

    def initialize(instruction, children=[])
      @instruction = instruction
      @children = children
    end

    def start(context)
      fail_silently { run(context) }
    end

    def run(_context)
      raise "#{self.class} does not implement #process"
    end

    def add_child(node)
      @children << node
    end

    private

    def fail_silently(&_block)
      yield if block_given?
    rescue EXEL::Error::JobTermination => e
      EXEL.logger.error "JobTerminationError: #{e.message.chomp}"
    end
  end
end
